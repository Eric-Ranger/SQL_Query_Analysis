Use OdyReporting;

Select Distinct
	CF.CaseID
	,cf.CaseNumberCur
	,cNLR.County As DispCounty
	,fNLR.County As FilingCounty
	,dfUCJ.CodeDescription As FilingDegree
	,ddUCJ.CodeDescription As DispoDegree
	,fDD.Date as FilingDate
	,Case
		When JurisdictionCodeDesc = 'State' And IssuingAgencyCodeDesc is not Null
			Then IssuingAgencyCodeDesc
		Else JurisdictionCodeDesc
	End As Entity
	,DIS.DispositionDate
From Criminal.CaseFiling CF
	Join Criminal.CaseDegree CD ON CF.CaseID = CD.CaseID
	Join dbo.NodeListReporting cNLR ON cNLR.NodeID = CF.NodeIDCur
	Join dbo.NodeListReporting fNLR ON fNLR.NodeID = CF.NodeIDFiling
	Join Shared.UserCode_Justice dfUCJ ON dfUCJ.CodeID = CD.CaseDegreeCodeID_Filing
	Join Shared.UserCode_Justice ddUCJ ON ddUCJ.CodeID = CD.CaseDegreeCodeID_Disposition
	Join Shared.DateDim fDD ON CF.DateFiledKey = fDD.DateKey
	Join Criminal.Charge C ON C.CaseID = CF.CaseID
	Join (	Select 
				dDD.Date As DispositionDate
				,DEC.CaseID
				,ROW_NUMBER() OVER(Partition By DEC.CaseID Order By dDD.date DESC) As ChargeRank
			From Criminal.DispositionEventCharge DEC
				Join Shared.DateDim dDD ON DEC.DateDispositionKey = dDD.DateKey
			Where isCurrent = 1
		) DIS ON CF.CaseID = DIS.CaseID
Where
	CF.DateFiledKey >= 20200101
		And 
	(cNLR.County = 'Benewah' Or fNLR.County = 'Benewah')
		And
	DIS.ChargeRank = 1
