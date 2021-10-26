# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    include ActionPolicy::GraphQL::Behaviour

    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    field(
      :users,
      resolver: Resolvers::UsersResolver,
      connection: true,
      preauthorize: { record: ::User, with: ::UserPolicy, to: :index? }
    )

    field :user, resolver: Resolvers::UserResolver, authorize: { with: UserPolicy }

    field :departments, resolver: Resolvers::DepartmentsResolver, description: <<~DESC
      A list of available/valid departments. List available at `config/departments.yml`
    DESC

    field(
      :roles,
      resolver: Resolvers::RolesResolver,
      connection: true,
      preauthorize: { record: ::Role, with: ::RolePolicy, to: :index? }
    )
    field :role, resolver: Resolvers::RoleResolver, authorize: { with: RolePolicy }

    field :permissions, resolver: Resolvers::PermissionsResolver, description: <<~DESC
      A list of valid permissions for different resources with respect for individual roles`
    DESC

    field :activities, resolver: Resolvers::ActivitiesResolver
    field :activity_actions, resolver: Resolvers::ActivityActionsResolver

    field(:admin_toolkit_footprints,
          resolver: Resolvers::AdminToolkit::FootprintsResolver,
          preauthorize: { with: ::AdminToolkitPolicy, to: :index? })

    field(:admin_toolkit_pcts,
          resolver: Resolvers::AdminToolkit::PctsResolver,
          preauthorize: { with: ::AdminToolkitPolicy, to: :index? })

    field(:admin_toolkit_labels, resolver: Resolvers::AdminToolkit::LabelsResolver)

    field(:admin_toolkit_project_cost,
          resolver: Resolvers::AdminToolkit::ProjectCostResolver,
          preauthorize: { with: ::AdminToolkitPolicy, to: :index? })

    field(:admin_toolkit_penetrations,
          resolver: Resolvers::AdminToolkit::PenetrationsResolver,
          connection: true,
          preauthorize: { with: ::AdminToolkitPolicy, to: :index? })

    field :penetration_types, resolver: Resolvers::AdminToolkit::PenetrationTypesResolver

    field(:admin_toolkit_competitions,
          resolver: Resolvers::AdminToolkit::CompetitionsResolver,
          connection: true,
          preauthorize: { with: ::AdminToolkitPolicy, to: :index? })

    field(:admin_toolkit_kam_investors,
          resolver: Resolvers::AdminToolkit::KamInvestorsResolver,
          connection: true,
          preauthorize: { with: ::AdminToolkitPolicy, to: :index? })

    field(:admin_toolkit_kam_regions,
          resolver: Resolvers::AdminToolkit::KamRegionsResolver,
          connection: true,
          preauthorize: { with: ::AdminToolkitPolicy, to: :index? })

    field(
      :projects,
      resolver: Resolvers::ProjectsResolver,
      connection: true,
      preauthorize: { record: ::Project, with: ::ProjectPolicy, to: :index? }
    )

    field :project, resolver: Resolvers::ProjectResolver, authorize: { with: ProjectPolicy }
    field :project_pct_cost, resolver: Resolvers::Projects::PctCostResolver
    field :project_states, resolver: Resolvers::Projects::StatesResolver, description: <<~DESC
      All possible states that any project may/may not have.
    DESC

    field(
      :buildings,
      resolver: Resolvers::Projects::BuildingsResolver,
      connection: true,
      preauthorize: { record: ::Project, with: ::ProjectPolicy }
    )

    field(
      :building,
      resolver: Resolvers::Projects::BuildingResolver,
      authorize: { record: ::Project, with: ProjectPolicy }
    )

    field :tasks, resolver: Resolvers::Projects::TasksResolver, authorize: { with: ProjectPolicy, record: Project }
    field :task, resolver: Resolvers::Projects::TaskResolver, authorize: { with: ProjectPolicy, record: Project }

    field :files, resolver: Resolvers::Projects::FilesResolver, authorize: { with: ProjectPolicy, record: Project }
    field :file, resolver: Resolvers::Projects::FileResolver, authorize: { with: ProjectPolicy, record: Project }
  end
end
