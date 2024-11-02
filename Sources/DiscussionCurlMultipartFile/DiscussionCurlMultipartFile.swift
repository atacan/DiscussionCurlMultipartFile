import ArgumentParser
import Hummingbird
import Logging

@main
struct AppCommand: AsyncParsableCommand, AppArguments {
    @Option(name: .shortAndLong)
    var hostname: String = "127.0.0.1"

    @Option(name: .shortAndLong)
    var port: Int = 8080

    @Option(name: .shortAndLong)
    var logLevel: Logger.Level?

    func run() async throws {
        let app = try await buildApplication(self)

        try await app.runService()
    }
}

/// Extend `Logger.Level` so it can be used as an argument
#if hasFeature(RetroactiveAttribute)
extension Logger.Level: @retroactive ExpressibleByArgument {}
#else
extension Logger.Level: ExpressibleByArgument {}
#endif

import OpenAPIHummingbird

/// Application arguments protocol. We use a protocol so we can call
/// `buildApplication` inside Tests as well as in the App executable.
/// Any variables added here also have to be added to `App` in App.swift and
/// `TestArguments` in AppTest.swift
public protocol AppArguments {
    var hostname: String { get }
    var port: Int { get }
    var logLevel: Logger.Level? { get }
}

// Request context used by application
typealias AppRequestContext = BasicRequestContext

///  Build application
/// - Parameter arguments: application arguments
public func buildApplication(_ arguments: some AppArguments) async throws -> some ApplicationProtocol {
    let environment = try await Environment().merging(with: .dotEnv())

    let logger = {
        var logger = Logger(label: "speech-router-hb")
        logger.logLevel =
        arguments.logLevel ?? environment.get("LOG_LEVEL").flatMap { Logger.Level(rawValue: $0) } ?? .debug
        return logger
    }()

    let router = try buildRouter()

    let app = Application(
        router: router,
        configuration: .init(
            address: .hostname(arguments.hostname, port: arguments.port),
            serverName: "speech-router-hb"
        ),
        logger: logger
    )
    return app
}

/// Build router
func buildRouter() throws -> Router<AppRequestContext> {
    let router = Router(context: AppRequestContext.self)
    // Add middleware
    router.addMiddleware {
        // logging middleware
        LogRequestsMiddleware(.info)
    }
    // Add default endpoint
    router.get("/") { _, _ in
        "Hello!"
    }

    let apiGeneratedByOpenAPI = ServerAPI()
    try apiGeneratedByOpenAPI.registerHandlers(on: router)

    return router
}

struct ServerAPI: APIProtocol {
    func uploadAudio(_ input: Operations.uploadAudio.Input) async throws -> Operations.uploadAudio.Output {
        switch input.body {
        case .multipartForm(let multiPartBody):
            for try await part in multiPartBody {
                switch part {
                case .file(let filePart):
                    for try await _ in filePart.payload.body {
                        print(".")
                    }
                case .model(let modelPart):
                    for try await _ in modelPart.payload.body {
                        print(".")
                    }
                }
            }
        }

        return .ok(.init(body: .json(.init(text: "text", duration: 382))))
    }
}
