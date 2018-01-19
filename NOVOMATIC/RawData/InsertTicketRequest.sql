USE AGS_RawData_Elaborate_Stag_Agile

DECLARE @requestClaimantID int

EXEC   [ETL].[InsertClaimant]
             @requestClaimantName = N'Gianpiero',
             @requestClaimantEmail = N'g.andrenacci@novomatic.it',
             @requestClaimantFolder = N'Gianpiero',
             @requestClaimantID = @requestClaimantID OUTPUT

SELECT @requestClaimantID as N'@requestClaimantID'

--INSERISCE LA RICHIESTA

declare @tv [ETL].[TicketTbl]

insert into @tv  Values
('533958039766720263', null, 1),
('265239871909816780', null, 1),
('338334649010885794', null, 1),
('236008118217048436', null, 1),
('197509543653522844', null, 1),
('32012290029658696', null, 1),
('492010228009679011', null, 1),
('88219393072236406', null, 1),
('184900000258351464', null, 1),
('187409635903007212', null, 1),
('99423485333135999', null, 1),
('323515774823344490', null, 1),
('484750221542191423', null, 1),
('483204789230060952', null, 1),
('193214988315353295', null, 1),
('237847051839061774', null, 1),
('171026912597342666', null, 1),
('397242152671325111', null, 1),
('56475667868570002', null, 1),
('275639671296184216', null, 1),
('270588514881081322', null, 1),
('493067133993436298', null, 1),
('373886395734340701', null, 1),
('195329555339972363', null, 1),
('145120357067038360', null, 1),
('483981869287787940', null, 1),
('90295615054876209', null, 1),
('250365885080433436', null, 1),
('498027305518704982', null, 1),
('324566220954573720', null, 1),
('357009235677460096', null, 1),
('471933214673108180', null, 1),
('198008859193586444', null, 1),
('181041814225405922', null, 1),
('329449701853978204', null, 1),
('34574425336320770', null, 1),
('35387239022619951', null, 1),
('35531412485910206', null, 1),
('36372538582939933', null, 1),
('37118007545645591', null, 1),
('37230501551260026', null, 1),
('39231818346751118', null, 1),
('62051769854867956', null, 1),
('85221228956305493', null, 1),
('90529396428713475', null, 1),
('111245020144689627', null, 1),
('115225045691871769', null, 1),
('135176165039264391', null, 1),
('135990147503314974', null, 1),
('136785575725801046', null, 1),
('159009935070807752', null, 1),
('159182970806592770', null, 1),
('159938266955300737', null, 1),
('184754519266399519', null, 1),
('211721484656348702', null, 1),
('233078124016190030', null, 1),
('236159161766188459', null, 1),
('262312420268749334', null, 1),
('310846512740292252', null, 1),
('311606000396589095', null, 1),
('312198980747585034', null, 1),
('312929400097044329', null, 1),
('332654638988735672', null, 1),
('333403268932592981', null, 1),
('335323978343033235', null, 1),
('335219661853075162', null, 1),
('360128684965893827', null, 1),
('361255478190205870', null, 1),
('387275696506676088', null, 1),
('409687934821468199', null, 1),
('410886814958450706', null, 1),
('411399187272726254', null, 1),
('433000123993323992', null, 1),
('435183822698280195', null, 1),
('436005913731274990', null, 1),
('455882129476163293', null, 1),
('460944417929582788', null, 1),
('505543221096858660', null, 1),
('505559164398724508', null, 1),
('507481591414654603', null, 1),
('556126940512849881', null, 1),
('557326233093953614', null, 1),
('558263704244783357', null, 1),
('560888720060759399', null, 1),
('561684422359771939', null, 1),
('561976892138492653', null, 1),
('29784470895580789', null, 1),
('35263956298645762', null, 1),
('54205861774714963', null, 1),
('54986240152531527', null, 1),
('56014282978197081', null, 1),
('57149253918756065', null, 1),
('58657371508202740', null, 1),
('80858848275883070', null, 1),
('83239771787055826', null, 1),
('105068307204856150', null, 1),
('105940082248873681', null, 1),
('108039531122748318', null, 1),
('131807468129114541', null, 1)

Declare @ConcessionaryID TinyInt = 4

exec [ETL].[InsertRequest] @requestClaimantID,'Gdf',@tv,4

