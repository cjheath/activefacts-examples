require 'activefacts/api'

module ::CinemaBookings

  class CinemaID < AutoCounter
    value_type 
    one_to_one :cinema                          # See Cinema.cinema_id
  end

  class DateTimeValue < DateTime
    value_type 
    one_to_one :date_time                       # See DateTime.date_time_value
  end

  class FilmID < AutoCounter
    value_type 
    one_to_one :film                            # See Film.film_id
  end

  class Name < String
    value_type 
    one_to_one :person, :counterpart => :login_name  # See Person.login_name
  end

  class Number < UnsignedInteger
    value_type :length => 16
    restrict 1..Infinity
  end

  class PersonID < AutoCounter
    value_type 
    one_to_one :person                          # See Person.person_id
  end

  class RowNr < Char
    value_type :length => 2
  end

  class SeatNumber < UnsignedInteger
    value_type :length => 16
  end

  class SectionName < String
    value_type 
    one_to_one :section                         # See Section.section_name
  end

  class Cinema
    identified_by :cinema_id
    one_to_one :cinema_id, :class => CinemaID, :mandatory => true  # See CinemaID.cinema
  end

  class DateTime
    identified_by :date_time_value
    one_to_one :date_time_value, :mandatory => true  # See DateTimeValue.date_time
  end

  class Film
    identified_by :film_id
    one_to_one :film_id, :class => FilmID, :mandatory => true  # See FilmID.film
    has_one :name                               # See Name.all_film
  end

  class Person
    identified_by :person_id
    one_to_one :login_name, :class => Name, :mandatory => true  # See Name.person_as_login_name
    one_to_one :person_id, :class => PersonID, :mandatory => true  # See PersonID.person
  end

  class Row
    identified_by :cinema, :row_nr
    has_one :cinema, :mandatory => true         # See Cinema.all_row
    has_one :row_nr, :mandatory => true         # See RowNr.all_row
  end

  class Seat
    identified_by :row, :seat_number
    has_one :row, :mandatory => true            # See Row.all_seat
    has_one :seat_number, :mandatory => true    # See SeatNumber.all_seat
    has_one :section                            # See Section.all_seat
  end

  class Section
    identified_by :section_name
    one_to_one :section_name, :mandatory => true  # See SectionName.section
  end

  class Session
    identified_by :cinema, :date_time
    has_one :cinema, :mandatory => true         # See Cinema.all_session
    has_one :date_time, :mandatory => true      # See DateTime.all_session
    has_one :film, :mandatory => true           # See Film.all_session
  end

  class Booking
    identified_by :person, :session
    has_one :number, :mandatory => true         # See Number.all_booking
    has_one :person, :mandatory => true         # See Person.all_booking
    has_one :session, :mandatory => true        # See Session.all_booking
    maybe :is_confirmed
  end

  class SeatAllocation
    identified_by :booking, :allocated_seat
    has_one :allocated_seat, :class => Seat, :mandatory => true  # See Seat.all_seat_allocation_as_allocated_seat
    has_one :booking, :mandatory => true        # See Booking.all_seat_allocation
  end

end
