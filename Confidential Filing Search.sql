Use operations;

--Temp Table with OFS
IF OBJECT_ID('tempdb..#ofs') IS NOT NULL BEGIN DROP TABLE #ofs END

--fill ofs temp table
SELECT 
	Location
	,EFSPName
	,CaseNumber
	,CaseCategory
	,CaseTypeDesc
	,OrderNumber
	,EnvelopeID
	,FilingID
	,FilingType
	,FilingCodeDescription
	,FilingCode
	,RejectCode
	,RejectComment
	,FirmName
	,FilerEmail
	,FilerFirstName
	,FilerLastName
	,Status
	,DD2.Date As ReviewedDate
	,ReviewerEmail
	,ReviewerFirstName
	,ReviewerLastName
	,DD.Date As SubmittedDate
	,NLR.CountyNum
	,NLR.County
INTO #ofs
FROM [OdyReporting].[Report].[OFSReporting] OFS
	Left Join OdyReporting.dbo.NodeListReporting NLR ON OFS.Location = NLR.OrgUnitName
	Left Join OdyReporting.Shared.DateDim DD ON OFS.DateSubmittedKey = DD.DateKey
	Left Join OdyReporting.Shared.DateDim DD2 ON OFS.DateReviewKey = DD2.DateKey
 Where CaseCategory = 'Civil'
  And 
  			--filter to just complaints
	(FilingCodeDescription like '%complaint%' 
	and FilingCodeDescription not like '%Amended%' 
	and FilingCodeDescription not like '%Motion%'
	and FilingCodeDescription not like '%Answer%');

--cte combining document information and creating preference rank for case number link
With doc As (
Select Distinct
	D.DocumentID
	,D.DocumentTypeID
	,D.Name
	,D.Description
	,D.TimestampCreate
	,Case 
		When D.TimestampChange is Null then D.TimestampCreate
		Else D.TimestampChange
	End As TimeStamp
	,D.DocumentOrigMethodID
	,D.SecurityToken
	,D.OriginatingDocumentID
	,DV.DocumentVersionID
	,DV.EffectiveDate
	,DV.DocumentSecurityGroupID
	,DSC.NotForPublicView
	,SecC.Code SecGrpCode
	,SecC.Description SecGrpDes
	,DocC.Code DocTypeCode
	,DocC.Description DocTypeDes
	,PL.ParentTypeID
	,PL.ParentID
	,SPT.Description parentType
	,Case When PL.ParentTypeID  = 1 Then 1
		When PL.ParentTypeID = 2 Then 2
		When PL.ParentTypeID = 3 Then 3
		When PL.ParentTypeID = 4 then 4
		Else 5
	End As likerate
From dbo.Doc D
	Left Join dbo.DocVersion DV ON D.DocumentID = DV.DocumentID
	Left Join dbo.uDocSecGrp DSC ON DV.DocumentSecurityGroupID = DSC.DocumentSecurityGroupID
	Left Join dbo.uCode SecC ON DV.DocumentSecurityGroupID = SecC.CodeID
	Left Join dbo.uCode DocC ON D.DocumentTypeID = DocC.CodeID
	Left Join dbo.ParentLink PL ON D.DocumentID = PL.DocumentID
	Left Join Operations.dbo.sParentType sPT ON PL.ParentTypeID = SPT.ParentTypeID
Where 
	
			--filter to just complaints
	Name like '%complaint%' 
	and Name not like '%Amended%' 
	and Name not like '%Motion%'
	and Name not like '%Answer%'
	And Name not like 'Summons%'
	and Name not like '%Affidavit%'
	and D.TimestampCreate > '2016-01-01'
),

--cte pulling in case number and row_number() ranking based on previous preference rank
DocCase As (
Select 
	d.*
	,CAHsub.CaseNbr As CaseNumber
	,CAHsub.CountyNum

	,ROW_NUMBER() Over(Partition By d.DocumentID Order By d.likerate) As RankCaseID -- rank by prefered link method
From doc d

	Left Join (
		Select 
			CAH.CaseID
			,CAH.CaseNbr
			,NLR.CountyNum
		From Justice.dbo.CaseAssignHist CAH
			Join OdyReporting.dbo.NodeListReporting NLR ON CAH.NodeID = NLR.NodeID
			) CAHsub ON d.parentID = CAHsub.caseID And d.ParentTypeID = 1 
	)
--combining OFS temp table with final DocCase cte
--Joining on CaseNumber for perfered link types and e files with status accepted 

Select Distinct
	ofs.CaseNumber
	,CaseCategory
	,Location
	,ofs.FilingID
	,ofs.FilingCodeDescription
	,dc.Name As DocDesc
	,ofs.FilingType
	,ofs.FilerLastName
	,ofs.FilerFirstName
	,ofs.FilerEmail
	,dc.DocumentID
	,ofs.Status
	,ofs.ReviewerLastName
	,ofs.ReviewerFirstName
	,ofs.ReviewerEmail
	,ofs.SubmittedDate
	,ofs.ReviewedDate
	,dc.TimestampCreate TimestampCreateDoc
	,Cast(dc.EffectiveDate as Date) As EffectiveDate
	,dc.NotForPublicView
	,DATEDIFF(DAY,SubmittedDate,TimestampCreate) As DaysSumbitedToPublic --Calculate hour/24 till timestampcreated

From #ofs ofs 
	Left Join DocCase dc ON ofs.CaseNumber = dc.CaseNumber and Status = 'Accepted' And ofs.CountyNum = dc.CountyNum

Where  
	(NotForPublicView = 0
	And (Cast(ofs.ReviewedDate As date) <= Cast(dc.TimestampCreate As date)
		and Cast(ofs.SubmittedDate As date) = Cast(dc.EffectiveDate As date)))
	Or Status = 'Rejected'
Order by
	reviewedDate asc