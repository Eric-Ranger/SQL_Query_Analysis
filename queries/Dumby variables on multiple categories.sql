Use OdyReporting;
--minidoka and cassia cases this year
IF OBJECT_ID('tempdb..#cases') IS NOT NULL BEGIN DROP TABLE #cases END

Select Distinct 
	CF.CaseID
	,DD.Month As FiledMonthNum
	,DD.MonthName_Short As FiledMonth
Into #cases
From OdyReporting.Shared.CaseFilingFact CF
	Join OdyReporting.dbo.NodeListReporting NLR ON NLR.NodeID = cf.NodeIDFiling
	Join OdyReporting.Shared.DateDim DD ON CF.DateFiledKey = DD.DateKey
Where
	 NLR.County in ('Minidoka','Cassia')
		 And
	 CF.DateFiledKey >= 20220101;

--add domestic violence dumby column
With cdv As (

Select Distinct 
	CF.CaseID
	,CF.filedMonthNum
	,FiledMonth
	,Case When CD.rankcharge = 1 Then 1 Else 0 End As HasDVC
	,Case When CC.rankcharge = 1 Then 1 Else 0 End As HasChildInjury
	,Case When CPA.CaseID is not null Then 1 Else 0 End As HasChildProtection
	,Case When CP.CaseID is not null Then 1 Else 0 End As HasCivilProtectionOrder
From #cases CF
	 Left Join
		( Select 
			c.CaseID
			,ROW_NUMBER() Over(Partition By Caseid Order by datechargefiledkey desc) rankcharge
		  From OdyReporting.Criminal.Charge C 
				Join OdyReporting.Shared.UserCode_Justice UCJ ON C.OffenseCodeIDFiling = UCJ.CodeID
		  Where
			(UCJ.CodeWord like '%18-918%' 
				or UCJ.CodeWord like '%39-6312%' 
				or UCJ.CodeWord like '%18-920%') -- Domestic Violence
			
		) CD ON CF.CaseID = CD.CaseID and CD.rankcharge = 1

	 Left Join
		( Select 
			c.CaseID
			,ROW_NUMBER() Over(Partition By Caseid Order by datechargefiledkey desc) rankcharge
		  From OdyReporting.Criminal.Charge C 
				Join OdyReporting.Shared.UserCode_Justice ucj ON C.OffenseCodeIDFiling = ucj.CodeID
		  Where
	 (ucj.CodeDescription like '%child%injury%') -- Injury to Child

			
		) CC ON CF.CaseID = CC.CaseID and CC.rankcharge = 1

	 Left Join
		( Select 
			c.CaseID
		  From OdyReporting.civil.CaseFiling C 
		  Where
			c.CaseTypeCodeID = 4647 -- Child Protection Act
		) CPA ON CF.CaseID = CPA.CaseID 

	 Left Join
		( Select 
			c.CaseID
		  From OdyReporting.civil.CaseFiling C 
		  Where
			c.CaseTypeCodeID in (1558,8167,17884) --civil protection Order Cases
		) CP ON CF.CaseID = CP.CaseID 
	)

	Select *
	From cdv
	Where HasDVC = 1 or HasChildInjury = 1 or HasChildProtection = 1 or HasCivilProtectionOrder = 1