import Foundation

/// Known development frameworks
public enum DevFramework: String, Codable, CaseIterable, Sendable {
    // JavaScript/TypeScript
    case next
    case vite
    case cra  // create-react-app
    case remix
    case nuxt
    case astro
    case svelte
    case gatsby
    case webpack
    case express
    case hono
    case elysia
    case koa
    case fastify

    // Python
    case flask
    case django
    case fastapi
    case uvicorn
    case gunicorn
    case streamlit
    case gradio

    // Ruby
    case rails
    case puma
    case sinatra

    // Rust
    case cargo

    // Go
    case gin
    case echo

    // Java/JVM
    case spring
    case quarkus
    case gradle

    // PHP
    case laravel

    // Elixir
    case phoenix

    /// Human-readable display name
    public var displayName: String {
        switch self {
        case .cra: return "react"
        case .fastapi: return "fastapi"
        case .uvicorn: return "uvicorn"
        case .gunicorn: return "gunicorn"
        case .streamlit: return "streamlit"
        case .gradio: return "gradio"
        case .fastify: return "fastify"
        default: return rawValue
        }
    }
}

/// Detects the framework from a process command string
public struct FrameworkDetector {

    /// Detect the framework from a command string.
    /// Order matters: more specific patterns are checked first.
    public static func detect(from command: String?) -> DevFramework? {
        guard let cmd = command?.lowercased() else { return nil }

        // JavaScript / TypeScript frameworks (specific before generic)
        if cmd.contains("next-server") || cmd.contains("next dev") || cmd.contains("next start") || cmd.contains(".bin/next") || cmd.contains(".next/") {
            return .next
        }
        if cmd.contains("remix") { return .remix }
        if cmd.contains("nuxt") { return .nuxt }
        if cmd.contains("astro") { return .astro }
        if cmd.contains("svelte") || cmd.contains("svelte-kit") { return .svelte }
        if cmd.contains("gatsby") { return .gatsby }
        if cmd.contains("react-scripts") { return .cra }
        if cmd.contains("vite") { return .vite }
        if cmd.contains("webpack") && cmd.contains("serve") { return .webpack }
        if cmd.contains("fastify") { return .fastify }
        if cmd.contains("hono") { return .hono }
        if cmd.contains("elysia") { return .elysia }
        if cmd.contains("koa") { return .koa }

        // Python frameworks
        if cmd.contains("streamlit") { return .streamlit }
        if cmd.contains("gradio") { return .gradio }
        if cmd.contains("fastapi") { return .fastapi }
        if cmd.contains("uvicorn") { return .uvicorn }
        if cmd.contains("gunicorn") { return .gunicorn }
        if cmd.contains("flask") { return .flask }
        if cmd.contains("django") || cmd.contains("manage.py") { return .django }

        // Ruby
        if cmd.contains("rails") { return .rails }
        if cmd.contains("puma") { return .puma }
        if cmd.contains("sinatra") { return .sinatra }

        // Rust
        if cmd.contains("cargo") && (cmd.contains("run") || cmd.contains("watch")) { return .cargo }

        // Go
        if cmd.contains("gin") { return .gin }
        if cmd.contains("echo") && cmd.contains("go") { return .echo }

        // Java/JVM
        if cmd.contains("spring") || cmd.contains("spring-boot") { return .spring }
        if cmd.contains("quarkus") { return .quarkus }
        if cmd.contains("gradle") && cmd.contains("bootRun") { return .gradle }

        // PHP
        if cmd.contains("artisan") || cmd.contains("laravel") { return .laravel }

        // Elixir
        if cmd.contains("phx.server") || cmd.contains("phoenix") { return .phoenix }

        // Generic JS server (check last, after all specific frameworks)
        if cmd.contains("express") { return .express }

        return nil
    }
}
