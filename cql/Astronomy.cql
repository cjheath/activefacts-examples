vocabulary Astronomy;

/*
 * Value Types
 */
AstronomicalObject Code is written as String(12);
Mass is written as Real(32);
Moon Name is written as String(256);
Nr Days is written as Real(32);
Planet Name is written as String(256);

/*
 * Entity Types
 */
AstronomicalObject is identified by its Code;
AstronomicalObject has at most one Mass;

Moon is a kind of AstronomicalObject identified by its Name;

Orbit is where
	AstronomicalObject is in orbit;
Orbit is around one AstronomicalObject (as Center) /* [acyclic, stronglyintransitive] */;
Orbit has a synodic period of at most one Nr Days;

Planet is a kind of AstronomicalObject identified by its Name;

Star is a kind of AstronomicalObject;

/*
 * Constraints:
 */
for each AstronomicalObject exactly one of these holds:
	AstronomicalObject is a Star,
	AstronomicalObject is a Planet,
	AstronomicalObject is a Moon;
