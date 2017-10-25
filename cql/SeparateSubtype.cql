vocabulary SeparateSubtype;

/*
 * Value Types
 */
Claim ID is written as Auto Counter;
Date Time is written as Date Time;
Person Name is written as String;

/*
 * Entity Types
 */
Claim is identified by its ID;

Incident is identified by Claim where
	Claim concerns at most one Incident,
	Incident resulted in one Claim;
Incident occurred on at most one Date Time;

Person is identified by its Name;

Vehicle Incident is a kind of Incident [separate];

Witness is a kind of Person;
Witness saw at least one Incident,
	Incident was independently witnessed by at most one Witness;

Driver is a kind of Person;
Vehicle Incident occurred while at most one Driver was in charge;

/*
 * Constraints:
 */
for each Incident, Person at most one of these holds:
	Incident is a Vehicle Incident that occurred while Driver was in charge and Driver is a kind of Person,
	Incident was independently witnessed by Witness;
