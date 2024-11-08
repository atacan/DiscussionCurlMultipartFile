// Generated by swift-openapi-generator, do not modify.
@_spi(Generated) import OpenAPIRuntime
#if os(Linux)
@preconcurrency import struct Foundation.URL
@preconcurrency import struct Foundation.Data
@preconcurrency import struct Foundation.Date
#else
import struct Foundation.URL
import struct Foundation.Data
import struct Foundation.Date
#endif
import HTTPTypes
extension APIProtocol {
    /// Registers each operation handler with the provided transport.
    /// - Parameters:
    ///   - transport: A transport to which to register the operation handlers.
    ///   - serverURL: A URL used to determine the path prefix for registered
    ///   request handlers.
    ///   - configuration: A set of configuration values for the server.
    ///   - middlewares: A list of middlewares to call before the handler.
    public func registerHandlers(
        on transport: any ServerTransport,
        serverURL: Foundation.URL = .defaultOpenAPIServerURL,
        configuration: Configuration = .init(),
        middlewares: [any ServerMiddleware] = []
    ) throws {
        let server = UniversalServer(
            serverURL: serverURL,
            handler: self,
            configuration: configuration,
            middlewares: middlewares
        )
        try transport.register(
            {
                try await server.uploadAudio(
                    request: $0,
                    body: $1,
                    metadata: $2
                )
            },
            method: .post,
            path: server.apiPathComponentsWithServerPrefix("/upload-audio")
        )
    }
}

fileprivate extension UniversalServer where APIHandler: APIProtocol {
    /// - Remark: HTTP `POST /upload-audio`.
    /// - Remark: Generated from `#/paths//upload-audio/post(uploadAudio)`.
    func uploadAudio(
        request: HTTPTypes.HTTPRequest,
        body: OpenAPIRuntime.HTTPBody?,
        metadata: OpenAPIRuntime.ServerRequestMetadata
    ) async throws -> (HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?) {
        try await handle(
            request: request,
            requestBody: body,
            metadata: metadata,
            forOperation: Operations.uploadAudio.id,
            using: {
                APIHandler.uploadAudio($0)
            },
            deserializer: { request, requestBody, metadata in
                let headers: Operations.uploadAudio.Input.Headers = .init(accept: try converter.extractAcceptHeaderIfPresent(in: request.headerFields))
                let contentType = converter.extractContentTypeIfPresent(in: request.headerFields)
                let body: Operations.uploadAudio.Input.Body
                let chosenContentType = try converter.bestContentType(
                    received: contentType,
                    options: [
                        "multipart/form-data"
                    ]
                )
                switch chosenContentType {
                case "multipart/form-data":
                    body = try converter.getRequiredRequestBodyAsMultipart(
                        OpenAPIRuntime.MultipartBody<Components.Schemas.UploadRequest>.self,
                        from: requestBody,
                        transforming: { value in
                            .multipartForm(value)
                        },
                        boundary: contentType.requiredBoundary(),
                        allowsUnknownParts: false,
                        requiredExactlyOncePartNames: [
                            "file"
                        ],
                        requiredAtLeastOncePartNames: [],
                        atMostOncePartNames: [
                            "model"
                        ],
                        zeroOrMoreTimesPartNames: [],
                        decoding: { part in
                            let headerFields = part.headerFields
                            let (name, filename) = try converter.extractContentDispositionNameAndFilename(in: headerFields)
                            switch name {
                            case "file":
                                try converter.verifyContentTypeIfPresent(
                                    in: headerFields,
                                    matches: "text/plain"
                                )
                                let body = try converter.getRequiredRequestBodyAsBinary(
                                    OpenAPIRuntime.HTTPBody.self,
                                    from: part.body,
                                    transforming: {
                                        $0
                                    }
                                )
                                return .file(.init(
                                    payload: .init(body: body),
                                    filename: filename
                                ))
                            case "model":
                                try converter.verifyContentTypeIfPresent(
                                    in: headerFields,
                                    matches: "text/plain"
                                )
                                let body = try converter.getRequiredRequestBodyAsBinary(
                                    OpenAPIRuntime.HTTPBody.self,
                                    from: part.body,
                                    transforming: {
                                        $0
                                    }
                                )
                                return .model(.init(
                                    payload: .init(body: body),
                                    filename: filename
                                ))
                            default:
                                preconditionFailure("Unknown part should be rejected by multipart validation.")
                            }
                        }
                    )
                default:
                    preconditionFailure("bestContentType chose an invalid content type.")
                }
                return Operations.uploadAudio.Input(
                    headers: headers,
                    body: body
                )
            },
            serializer: { output, request in
                switch output {
                case let .ok(value):
                    suppressUnusedWarning(value)
                    var response = HTTPTypes.HTTPResponse(soar_statusCode: 200)
                    suppressMutabilityWarning(&response)
                    let body: OpenAPIRuntime.HTTPBody
                    switch value.body {
                    case let .json(value):
                        try converter.validateAcceptIfPresent(
                            "application/json",
                            in: request.headerFields
                        )
                        body = try converter.setResponseBodyAsJSON(
                            value,
                            headerFields: &response.headerFields,
                            contentType: "application/json; charset=utf-8"
                        )
                    }
                    return (response, body)
                case let .badRequest(value):
                    suppressUnusedWarning(value)
                    var response = HTTPTypes.HTTPResponse(soar_statusCode: 400)
                    suppressMutabilityWarning(&response)
                    return (response, nil)
                case let .unauthorized(value):
                    suppressUnusedWarning(value)
                    var response = HTTPTypes.HTTPResponse(soar_statusCode: 401)
                    suppressMutabilityWarning(&response)
                    return (response, nil)
                case let .internalServerError(value):
                    suppressUnusedWarning(value)
                    var response = HTTPTypes.HTTPResponse(soar_statusCode: 500)
                    suppressMutabilityWarning(&response)
                    return (response, nil)
                case let .undocumented(statusCode, _):
                    return (.init(soar_statusCode: statusCode), nil)
                }
            }
        )
    }
}
