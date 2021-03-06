if Rails.env.development?
  require 'active_record/fixtures'
  require 'faker'

  module ActiveRecord
    module ConnectionAdapters
      # nodoc
      class PostgreSQLAdapter < AbstractAdapter
        # PostgreSQL only disables referential integrity when connection
        # user is root and that is not the case.
        def disable_referential_integrity
          yield
        end
      end
    end
  end

  task load_fixtures: :environment do
    path = File.join(File.dirname(__FILE__), '..', '..', 'spec', 'fixtures')
    ActiveRecord::FixtureSet.create_fixtures(path, [
      :participants,
      :projects,
      :memberships,
      :addresses,
      :date_of_births,
      :education_levels,
      :emails,
      :ethnicities,
      :genders,
      :names,
      :phones,
      :races,
      :screenings,
      :statuses
    ])
  end
end
