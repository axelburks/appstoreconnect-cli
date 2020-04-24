// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine

struct ListUsersOperation: APIOperation {

    struct ListUsersDependencies {
        let users: (APIEndpoint<UsersResponse>) -> Future<UsersResponse, Error>
    }

    private let endpoint: APIEndpoint<UsersResponse>

    init(options: ListUsersOptions) {
        let include = options.includeVisibleApps ? [ListUsers.Include.visibleApps] : nil

        let limit = [
            options.limitUsers.map(ListUsers.Limit.users),
            options.limitVisibleApps.map(ListUsers.Limit.visibleApps)]
            .compactMap { $0 }
            .nilIfEmpty()

        let sort = options.sort.map { [$0] }

        typealias Filter = ListUsers.Filter

        let filter: [Filter]? = {
            let roles = options.filterRole.map(\.rawValue).nilIfEmpty().map(Filter.roles)
            let usernames = options.filterUsername.nilIfEmpty().map(Filter.username)
            let visibleApps = options.filterVisibleApps.nilIfEmpty().map(Filter.visibleApps)

            return [roles, usernames, visibleApps].compactMap({ $0 }).nilIfEmpty()
        }()

        endpoint = APIEndpoint.users(
            fields: nil,
            include: include,
            limit: limit,
            sort: sort,
            filter: filter,
            next: nil
        )
    }

    func execute(with dependencies: ListUsersDependencies) -> AnyPublisher<[User], Error> {
        dependencies.users(endpoint)
            .map(User.fromAPIResponse)
            .eraseToAnyPublisher()
    }
}