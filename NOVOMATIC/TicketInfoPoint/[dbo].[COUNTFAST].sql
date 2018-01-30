/*
SELECT dbo.COUNTFAST('[ETL].[Delta_OK]') AS ROWNUMBER
*/
ALTER FUNCTION [dbo].[COUNTFAST](@TableName varchar(128))
RETURNS bigint
AS
BEGIN
	DECLARE @RETVAL bigint = NULL

	IF ISNULL(@TableName,'') != ''
		BEGIN
			SELECT	@RETVAL = CONVERT(bigint, rows)
			FROM	sysindexes WITH(NOLOCK)
			WHERE	id = OBJECT_ID(@TableName)
			AND		indid < 2

			IF ISNULL(@RETVAL,0) = 0
				BEGIN
					SELECT	@RETVAL = SUM(st.row_count)
					FROM	sys.dm_db_partition_stats st WITH(NOLOCK)
					WHERE	OBJECT_ID = OBJECT_ID(@TableName)
					AND		(index_id < 2)
				END
		END
	RETURN @RETVAL
END