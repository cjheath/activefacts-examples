require 'activefacts/api'

module ::OneRoleNesting

  class AccuracyLevel < SignedInteger
    value_type :length => 32
    one_to_one :accuracy, :restrict => 1..5     # See Accuracy.accuracy_level
  end

  class PartyId < AutoCounter
    value_type 
    one_to_one :party                           # See Party.party_id
  end

  class PartyName < String
    value_type 
  end

  class Ymd < Date
    value_type 
    one_to_one :event_date                      # See EventDate.ymd
  end

  class Accuracy
    identified_by :accuracy_level
    one_to_one :accuracy_level, :mandatory => true  # See AccuracyLevel.accuracy
  end

  class EventDate
    identified_by :ymd
    one_to_one :ymd, :mandatory => true         # See ymd.event_date
  end

  class Party
    identified_by :party_id
    one_to_one :party_id, :mandatory => true    # See PartyId.party
  end

  class PartyMoniker
    identified_by :party
    one_to_one :party, :mandatory => true       # See Party.party_moniker
    has_one :party_name, :mandatory => true     # See PartyName.all_party_moniker
    has_one :accuracy, :mandatory => true       # See Accuracy.all_party_moniker
  end

  class Person < Party
    maybe :died
  end

  class Birth
    identified_by :person
    has_one :event_date_of_birth, :class => EventDate, :mandatory => true  # See EventDate.all_birth_as_event_date_of_birth
    one_to_one :person, :mandatory => true      # See Person.birth
    has_one :attending_doctor, :class => "Doctor"  # See Doctor.all_birth_as_attending_doctor
  end

  class Death
    identified_by :person
    one_to_one :person, :mandatory => true      # See Person.death
    has_one :death_event_date, :class => EventDate  # See EventDate.all_death_as_death_event_date
  end

  class Doctor < Person
  end

end
