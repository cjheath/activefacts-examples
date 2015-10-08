require 'activefacts/api'

module ::CompanyDirectorEmployee

  class CompanyName < String
    value_type :length => 48
    one_to_one :company                         # See Company.company_name
  end

  class Date < ::Date
    value_type 
  end

  class EmployeeNr < SignedInteger
    value_type :length => 32
    one_to_one :employee                        # See Employee.employee_nr
  end

  class Name < String
    value_type :length => 48
  end

  class Company
    identified_by :company_name
    one_to_one :company_name, :mandatory => true  # See CompanyName.company
    maybe :is_listed
  end

  class Employee
    identified_by :employee_nr
    has_one :company, :mandatory => true        # See Company.all_employee
    one_to_one :employee_nr, :mandatory => true  # See EmployeeNr.employee
    has_one :manager                            # See Manager.all_employee
  end

  class Manager < Employee
    maybe :is_ceo
  end

  class Meeting
    identified_by :company, :date, :is_board_meeting
    has_one :company, :mandatory => true        # See Company.all_meeting
    has_one :date, :mandatory => true           # See Date.all_meeting
    maybe :is_board_meeting
  end

  class Person
    identified_by :given_name, :family_name
    has_one :birth_date, :class => Date         # See Date.all_person_as_birth_date
    has_one :family_name, :class => Name        # See Name.all_person_as_family_name
    has_one :given_name, :class => Name, :mandatory => true  # See Name.all_person_as_given_name
  end

  class Attendance
    identified_by :attendee, :meeting
    has_one :attendee, :class => Person, :mandatory => true  # See Person.all_attendance_as_attendee
    has_one :meeting, :mandatory => true        # See Meeting.all_attendance
  end

  class Directorship
    identified_by :director, :company
    has_one :company, :mandatory => true        # See Company.all_directorship
    has_one :director, :class => Person, :mandatory => true  # See Person.all_directorship_as_director
    has_one :appointment_date, :class => Date, :mandatory => true  # See Date.all_directorship_as_appointment_date
  end

  class Employment
    identified_by :person, :employee
    has_one :employee, :mandatory => true       # See Employee.all_employment
    has_one :person, :mandatory => true         # See Person.all_employment
  end

end
