/*
EXEC ETL.GetMasterDetailSessionDeltaJSON 101
*/
ALTER PROC ETL.GetMasterDetailSessionDeltaJSON
			@requestId int = NULL
AS
IF ISNULL(@requestId,0) > 0
	BEGIN
		SELECT 
				 R.requestId AS 'Master.requestId'
				,R.requestDesc AS 'Master.requestDesc'
				,R.requestClaimantId AS 'Master.requestClaimantId'
				,R.elabStart AS 'Master.elabStart'
				,R.elabEnd AS 'Master.elabEnd'
				,R.requestStatusId AS 'Master.requestStatusId'
				,R.system_date AS 'Master.system_date'
				,R.ConcessionaryID AS 'Master.ConcessionaryID'
				,R.ClubID AS 'Master.ClubID'
				,R.FilterAmount AS 'Master.FilterAmount'
				,R.FilterStartDate AS 'Master.FilterStartDate'
				,R.FilterEndDate AS 'Master.FilterEndDate'
				,R.TipoRichiesta AS 'Master.TipoRichiesta'
				,Detail =
				(
					SELECT
							D.requestDetailId
							,D.requestId
							,D.ticket
							,D.clubId
							,D.ticketDirection
							,D.univocalLocationCode 
							,D.elabStart
							,D.elabEnd
							,D.detailStatusId
							,D.fileNameSession
							,D.fileNameDelta
							,D.fileNameOperationLog
							,D.fileNameErrorLog
							,D.system_date
							,Session =
							(
								SELECT
 										S.RecID
										,S.requestDetailId
										,S.SessionID
										,S.SessionParentID
										,S.[Level]
										,S.UnivocalLocationCode
										,S.MachineID
										,S.GD
										,S.AamsMachineCode
										,S.StartServerTime
										,S.EndServerTime
										,S.TotalRows
										,S.TotalBillIn
										,S.TotalCoinIN
										,S.TotalTicketIn
										,S.TotalBetValue
										,S.TotalBetNum
										,S.TotalWinValue
										,S.TotalWinNum
										,S.Tax
										,S.TotalIn
										,S.TotalOut
										,S.FlagMinVltCredit
										,S.StartTicketCode
										,Delta =
										(
											SELECT
													L.RecID
													,L.requestDetailId
													,L.RowID
													,L.UnivocalLocationCode
													,L.ServerTime
													,L.MachineID
													,L.GD
													,L.AamsMachineCode
													,L.GameID
													,L.GameName
													,L.VLTCredit
													,L.TotalBet
													,L.TotalWon
													,L.TotalBillIn
													,L.TotalCoinIn
													,L.TotalTicketIn
													,L.TotalHandPay
													,L.TotalTicketOut
													,L.Tax
													,L.TotalIn
													,L.TotalOut
													,L.WrongFlag
													,L.TicketCode
													,L.SessionID
											FROM	ETL.Delta L WITH(NOLOCK)
											WHERE	L.SessionID = S.SessionID
											FOR JSON PATH 
										)
								FROM	[ETL].[Session] S WITH(NOLOCK)
								WHERE	S.StartTicketCode = D.ticket
								FOR JSON PATH 
							)
					FROM	ETL.requestDetail D WITH(NOLOCK)
					WHERE	R.requestId = D.requestId
					FOR JSON PATH 
				)
		FROM	ETL.request R WITH(NOLOCK)
		WHERE	R.requestId = 100
		FOR JSON PATH 
	END