vocabulary Health;

vocabulary BasicTypes;

each Integer is written as an Int;
each Code is written as a String(16);
each ID is written as an Auto Counter;
each Date is written as a Date;
each Text is written as a String;
each Name is written as a String;
each Number is written as an Integer;

vocabulary PartyRoles;
each Party is identified by its ID;
each Stakeholder is a kind of Party;
each Policy Holder is a kind of Stakeholder;
each Claimant is a kind of Stakeholder;

vocabulary InsurerProducts;
// Insurer, Product, Available Coverage
each Insurer [static, separate] is identified by its Name;
each Product Offering [static, separate] is identified by its Name;
Product Offering is offered by one Insurer;
each Coverage Type [separate] is identified by its Name;
Coverage Type has at most one descriptive- Text;
each Available Coverage [static] is where
    Coverage Type is available in Product Offering,
    Product Offering offers Coverage Type;

vocabulary Policies;
// Policy, Policy Coverage
each Policy Number is written as an Integer;
each Policy is identified by Insurer and Policy Number where
    that Policy is from one Insurer, that Insurer issued that Policy,
    that Policy has one Policy Number;
Policy is held by one Policy Holder;
Policy was purchased from one Product Offering;
Policy was purchased on one [satellite stable] Date;

each Policy Coverage is where
    Policy includes Coverage Type;
each Coverage Level is written as an Integer;
Policy Coverage is at at most one Coverage Level;

some Policy includes some Coverage Type
    only if that Policy was purchased from some Product Offering that offers that Coverage Type;

vocabulary Incidents;
// Incident
each Incident Type [static, separate] is identified by its Name;
each Incident [separate] is identified by its ID;
each Incident is of one Incident Type;
each Incident occurred on one Date;
Incident has at most one descriptive- Text;

Incident affected one
    (according to Praneet, because we don't want to handle class actions yet, as agreed on 25 September by Clifford)
    Claimant;

vocabulary Claims;
// Claim and Details
each Claim [separate] is identified by its Number;
Claim concerns one Incident,
    Incident resulted in at most one Claim;

each Claim Details is where
    some Claim claims against some Policy Coverage on some Date,
    that Policy Coverage is claimed under that Claim for that Date;

vocabulary ClaimPayments;
// Claim Payment
Claim Payment [separate] is identified by Claim Details where
    Claim Payment is for one Claim Details,
    Claim Details is paid by at most one Claim Payment;

Claim Payment Type [independent, static] is identified by its Code;
Claim Payment Type has at most one descriptive-Text;
Claim Payment is of one Claim Payment Type;
