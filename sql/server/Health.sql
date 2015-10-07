CREATE TABLE AvailableCoverage (
	-- Available Coverage involves Coverage Type and Coverage Type has Coverage Type Name,
	CoverageTypeName                        varchar NOT NULL,
	-- Available Coverage involves Product Offering and Product Offering has Product Offering Name,
	ProductOfferingName                     varchar NOT NULL,
	PRIMARY KEY(CoverageTypeName, ProductOfferingName)
)
GO

CREATE TABLE Claim (
	-- Claim has Claim Number,
	ClaimNumber                             Int NOT NULL,
	PRIMARY KEY(ClaimNumber)
)
GO

CREATE TABLE ClaimPayment (
	-- Claim Payment is for Claim Details and Claim Details involves Claim and Claim has Claim Number,
	ClaimDetailsClaimNumber                 Int NOT NULL,
	-- Claim Payment is for Claim Details and Claim Details involves Date,
	ClaimDetailsDate                        datetime NOT NULL,
	-- Claim Payment is for Claim Details and Claim Details involves Policy Coverage and Policy Coverage involves Policy and Policy is from Insurer and Insurer has Insurer Name,
	ClaimDetailsPolicyCoveragePolicyInsurerName varchar NOT NULL,
	-- Claim Payment is for Claim Details and Claim Details involves Policy Coverage and Policy Coverage involves Policy and Policy has Policy Number,
	ClaimDetailsPolicyCoveragePolicyNumber  Int NOT NULL,
	-- Claim Payment is for Claim Details and Claim Details involves Policy Coverage and Policy Coverage involves Coverage Type and Coverage Type has Coverage Type Name,
	ClaimDetailsPolicyCoverageTypeName      varchar NOT NULL,
	-- Claim Payment is of Claim Payment Type and Claim Payment Type has Claim Payment Type Code,
	ClaimPaymentTypeCode                    varchar(16) NOT NULL,
	PRIMARY KEY(ClaimDetailsClaimNumber, ClaimDetailsPolicyCoveragePolicyInsurerName, ClaimDetailsPolicyCoveragePolicyNumber, ClaimDetailsPolicyCoverageTypeName, ClaimDetailsDate),
	FOREIGN KEY (ClaimDetailsClaimNumber) REFERENCES Claim (ClaimNumber)
)
GO

CREATE TABLE ClaimPaymentType (
	-- Claim Payment Type has Claim Payment Type Code,
	ClaimPaymentTypeCode                    varchar(16) NOT NULL,
	-- maybe Claim Payment Type has descriptive-Text,
	DescriptiveText                         varchar NULL,
	PRIMARY KEY(ClaimPaymentTypeCode)
)
GO

CREATE TABLE CoverageType (
	-- Coverage Type has Coverage Type Name,
	CoverageTypeName                        varchar NOT NULL,
	-- maybe Coverage Type has descriptive-Text,
	DescriptiveText                         varchar NULL,
	PRIMARY KEY(CoverageTypeName)
)
GO

CREATE TABLE Incident (
	-- maybe Incident resulted in Claim and Claim has Claim Number,
	ClaimNumber                             Int NULL,
	-- Incident affected Claimant and Claimant is a kind of Stakeholder and Stakeholder is a kind of Party and Party has Party ID,
	ClaimantID                              int NOT NULL,
	-- Incident occurred on Date,
	Date                                    datetime NOT NULL,
	-- maybe Incident has descriptive-Text,
	DescriptiveText                         varchar NULL,
	-- Incident has Incident ID,
	IncidentID                              int IDENTITY NOT NULL,
	-- Incident is of Incident Type and Incident Type has Incident Type Name,
	IncidentTypeName                        varchar NOT NULL,
	PRIMARY KEY(IncidentID),
	FOREIGN KEY (ClaimNumber) REFERENCES Claim (ClaimNumber)
)
GO

CREATE VIEW dbo.Incident_ClaimNumber (ClaimNumber) WITH SCHEMABINDING AS
	SELECT ClaimNumber FROM dbo.Incident
	WHERE	ClaimNumber IS NOT NULL
GO

CREATE UNIQUE CLUSTERED INDEX IX_IncidentByClaimNumber ON dbo.Incident_ClaimNumber(ClaimNumber)
GO

CREATE TABLE IncidentType (
	-- Incident Type has Incident Type Name,
	IncidentTypeName                        varchar NOT NULL,
	PRIMARY KEY(IncidentTypeName)
)
GO

CREATE TABLE Insurer (
	-- Insurer has Insurer Name,
	InsurerName                             varchar NOT NULL,
	PRIMARY KEY(InsurerName)
)
GO

CREATE TABLE Party (
	-- Party has Party ID,
	PartyID                                 int IDENTITY NOT NULL,
	PRIMARY KEY(PartyID)
)
GO

CREATE TABLE Policy (
	-- Policy was purchased on Date,
	Date                                    datetime NOT NULL,
	-- Policy is from Insurer and Insurer has Insurer Name,
	InsurerName                             varchar NOT NULL,
	-- Policy is held by Policy Holder and Policy Holder is a kind of Stakeholder and Stakeholder is a kind of Party and Party has Party ID,
	PolicyHolderID                          int NOT NULL,
	-- Policy has Policy Number,
	PolicyNumber                            Int NOT NULL,
	-- Policy was purchased from Product Offering and Product Offering has Product Offering Name,
	ProductOfferingName                     varchar NOT NULL,
	PRIMARY KEY(InsurerName, PolicyNumber),
	FOREIGN KEY (InsurerName) REFERENCES Insurer (InsurerName),
	FOREIGN KEY (PolicyHolderID) REFERENCES Party (PartyID)
)
GO

CREATE TABLE PolicyCoverage (
	-- maybe Policy Coverage is at Coverage Level,
	CoverageLevel                           Int NULL,
	-- Policy Coverage involves Coverage Type and Coverage Type has Coverage Type Name,
	CoverageTypeName                        varchar NOT NULL,
	-- Policy Coverage involves Policy and Policy is from Insurer and Insurer has Insurer Name,
	PolicyInsurerName                       varchar NOT NULL,
	-- Policy Coverage involves Policy and Policy has Policy Number,
	PolicyNumber                            Int NOT NULL,
	PRIMARY KEY(PolicyInsurerName, PolicyNumber, CoverageTypeName),
	FOREIGN KEY (CoverageTypeName) REFERENCES CoverageType (CoverageTypeName),
	FOREIGN KEY (PolicyInsurerName, PolicyNumber) REFERENCES Policy (InsurerName, PolicyNumber)
)
GO

CREATE TABLE ProductOffering (
	-- Product Offering is offered by Insurer and Insurer has Insurer Name,
	InsurerName                             varchar NOT NULL,
	-- Product Offering has Product Offering Name,
	ProductOfferingName                     varchar NOT NULL,
	PRIMARY KEY(ProductOfferingName),
	FOREIGN KEY (InsurerName) REFERENCES Insurer (InsurerName)
)
GO

ALTER TABLE AvailableCoverage
	ADD FOREIGN KEY (CoverageTypeName) REFERENCES CoverageType (CoverageTypeName)
GO

ALTER TABLE AvailableCoverage
	ADD FOREIGN KEY (ProductOfferingName) REFERENCES ProductOffering (ProductOfferingName)
GO

ALTER TABLE ClaimPayment
	ADD FOREIGN KEY (ClaimPaymentTypeCode) REFERENCES ClaimPaymentType (ClaimPaymentTypeCode)
GO

ALTER TABLE ClaimPayment
	ADD FOREIGN KEY (ClaimDetailsPolicyCoveragePolicyInsurerName, ClaimDetailsPolicyCoveragePolicyNumber, ClaimDetailsPolicyCoverageTypeName) REFERENCES PolicyCoverage (PolicyInsurerName, PolicyNumber, CoverageTypeName)
GO

ALTER TABLE Incident
	ADD FOREIGN KEY (IncidentTypeName) REFERENCES IncidentType (IncidentTypeName)
GO

ALTER TABLE Incident
	ADD FOREIGN KEY (ClaimantID) REFERENCES Party (PartyID)
GO

ALTER TABLE Policy
	ADD FOREIGN KEY (ProductOfferingName) REFERENCES ProductOffering (ProductOfferingName)
GO

