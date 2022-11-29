DECLARE 
	@PartySwitch INT, --switch between adult and Juvenile
        @DateRange Date; -- Date Range for the Case

SET @PartySwitch = 0 -- 0 For Adult, 1 for Juvenile
SET	@DateRange = '2016-01-01'


IF OBJECT_ID('tempdb.dbo.#db_party') IS NOT NULL
	DROP TABLE #db_party
IF OBJECT_ID('tempdb.dbo.#matched') IS NOT NULL
	DROP TABLE #matched

--Create Temp table for matched parties. Null PartyID means no match found
--Table will come Juvenile or Adult list based on Switch selection
CREATE TABLE #matched(
	PartyID INT,
	NameFirst VarChar(100),
	NameLast VarChar(100),
	DOB Date,
	Address VarChar(500),
	FamID INT,
	ijos_id INT,
	magic_id VarChar(30)
)

--Create Temp Table for database party information. Uses Justice
CREATE TABLE #db_party (
	PartyID INT NOT NULL,
	NameFirst VarChar(100),
	NameLast VarChar(100),
	DOB Date
)
	INSERT INTO #db_party (
		PartyID,
		NameFirst,
		NameLast,
		DOB
		)
	Select 
		P.PartyID, 
		N.NameFirst, 
		N.NameLast,
		DOB.DtDOB AS DOB
	From Justice.dbo.party P
		Join Justice.dbo.name N ON P.PartyID = N.PartyID
		Join Justice.dbo.DOB DOB ON P.DOBIDCur = DOB.DOBID;

-- Start IF/switch here 

IF @PartySwitch < 1 -- Adult
	BEGIN
		
	INSERT INTO #matched ( -- Insert into Temp table for Adult list
		PartyID,
		NameFirst,
		NameLast,
		DOB,
		Address,
		FamID,
		ijos_id,
		magic_id
	)
	Select Distinct 
		Case
		  When FirstName = 'dummy' Then 555555 - fake names for 
		  Else dp.PartyID 
		End As PartyID,
		ARR.FirstName,
		ARR.LastName,
		ARR.DOB,
		ARR.Address,
		ARR.FamID,
		ARR.ijos_id,
		ARR.magic_id
	From OdyReporting.dbo.ZZ_AdultRecordRequest ARR
		Left Join #db_party dp ON dp.DOB = ARR.DOB 
			  AND (DP.NameLast Like '%'+ARR.LastName+'%' OR ARR.LastName Like '%'+DP.NameLast+'%')
			  And Left(dp.NameFirst,1) = LEFT(ARR.FirstName,1)
	Order By PartyID;
	END

-- Next Swicth Option

Else  -- Juvenile
	BEGIN	
	
	INSERT INTO #matched ( -- Insert into Temp Table for Juvenile list
		PartyID,
		NameFirst,
		NameLast,
		DOB,
		Address,
		FamID,
		ijos_id,
		magic_id
		)
	Select Distinct 
		Case
			When FirstName = 'dummy' Then 555555
			Else dp.PartyID 
		End As PartyID,
		JRR.FirstName,
		JRR.LastName,
		JRR.TCdob,
		JRR.TCfullAddress,
		JRR.FamID,
		JRR.ijos_id,
		JRR.magic_id
	From OdyReporting.dbo.ZZ_JuvenileRecordRequest JRR
		Left Join #db_party dp ON dp.DOB = JRR.TCdob 
			  AND (DP.NameLast Like '%'+JRR.LastName+'%' OR JRR.LastName Like '%'+DP.NameLast+'%')
			  And Left(dp.NameFirst,1) = LEFT(JRR.FirstName,1)
	Order By PartyID;
	END
--end If

--Begin background Check Data Pull
	Select Distinct
		M.*,
		CP.CaseID,
		CF.CaseNumberCur,
		C.ChargeID,
		DD.Date As DateChargeFiled,
		UCJDF.CodeDescription As DegreeFiling,
		UCJDD.CodeDescription As DegreeDisposition,
		UCJOF.CodeDescription As OffenseFiling,
		UCJOD.CodeDescription As OffenseDisposition,
		DEC.DispositionEventID,
		UCJDT.CodeDescription As DispositionType,
		DEC.BaseDispositionTypeCode,
		PE.PleaTypeDesc,
		SB.SentenceID,
		DD2.Date As SentenceDate,
		SC.TypeDescription As FacilityType,
		SC.TermYears,
		SC.TermMonths,
		SC.TermDays,
		SC.SuspendedDays,
		SC.SuspendedMonths,
		SC.SuspendedYears,
		SC.DiscretionaryDays,
		SC.DiscretionaryMonths,
		SC.DiscretionaryYears,
		SC.IndeterminateDays,
		SC.IndeterminateMonths,
		SC.IndeterminateYears,
		SC.DeterminateDays,
		SC.DeterminateMonths,
		SC.DeterminateYears,
		SC.PenitentiarySuspendedFlag,
		SC.LifeFlag,
		SC.DeathFlag,
		SCon.Probation,
		SCon.DurationDays As ProbationDurationDays,
		Scon.DurationMonths As ProbationDurationMonths,
		Scon.DurationYears As ProbationDurationYears,
		NLR.District,
		NLR.County,
		NLR.CourtTypeDescription
	From #matched M
		Left Join OdyReporting.Shared.CaseParty CP ON M.PartyID = CP.PartyID and CP.BaseConnCode = 'DF'
		Left Join OdyReporting.Criminal.Charge C ON CP.CaseID = C.CaseID
		Left Join OdyReporting.Criminal.CaseFiling CF ON CP.CaseID = CF.CaseID
		Left Join OdyReporting.Criminal.DispositionEventCharge DEC ON C.ChargeID = DEC.ChargeID And DEC.isCurrent = 1
		Left Join OdyReporting.Criminal.PleaEvent PE ON C.ChargeID = PE.ChargeID And PE.isCurrent = 1
		Left Join OdyReporting.Criminal.SentenceBase SB ON C.ChargeID = SB.ChargeID And SB.isCurrent = 1
		Left Join OdyReporting.Criminal.SentenceConfinement SC ON SB.SentenceID = SC.SentenceID
		Left Join ( -- rank probation 1 to 1 for sentenceID and just pull in term "probation"
					Select 
						SentenceID,
						ConditionCodeID,
						ConditionCode,
						ConditionCodeDesc,
						DurationDays,
						DurationMonths,
						DurationYears,
						Probation = 'Probation',
						ROW_NUMBER() Over(Partition by SentenceID Order by DateConditionStartKey) As ProbRank
					From OdyReporting.Criminal.SentenceCondition SC
					Where ConditionCodeDesc like '%bation%'
						And ConditionCodeID <> 17213
					) SCon ON SB.SentenceID = SCon.SentenceID And ProbRank = 1
		Left Join OdyReporting.Shared.DateDim DD ON C.DateChargeFiledKey = DD.DateKey
		Left Join OdyReporting.Shared.DateDim DD2 ON SB.DateSentenceKey = DD2.DateKey
		Left Join OdyReporting.dbo.NodeListReporting NLR ON CF.NodeIDCur = NLR.NodeID
		Left Join OdyReporting.Shared.UserCode_Justice UCJDD ON C.DegreeCodeIDDispo = UCJDD.CodeID
		Left Join OdyReporting.Shared.UserCode_Justice UCJDF ON C.DegreeCodeIDFiling = UCJDF.CodeID
		Left Join OdyReporting.Shared.UserCode_Justice UCJOD ON C.OffenseCodeIDDispo = UCJOD.CodeID
		Left Join OdyReporting.Shared.UserCode_Justice UCJOF ON C.OffenseCodeIDFiling = UCJOF.CodeID
		Left Join OdyReporting.Shared.UserCode_Justice UCJDT ON DEC.CriminalDispositionTypeCodeID = UCJDT.CodeID
	Where 
		(((@PartySwitch = 0 And (CourtTypeID in (1,2,0)) OR (@PartySwitch = 1 And (CourtTypeID in (3))))
			And DD.Date >= @DateRange)
	  OR 
		M.PartyID is Null)
	Order By m.NameLast, m.NameFirst
