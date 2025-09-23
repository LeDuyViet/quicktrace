import Foundation

/// Defines different output formats for the tracer
public enum OutputStyle: Int, CaseIterable {
    /// Simple default format
    case `default` = 0
    
    /// Modern colorful format with Unicode borders
    case colorful = 1
    
    /// Compact tree view format
    case minimal = 2
    
    /// Full analysis with statistics
    case detailed = 3
    
    /// Clean table format
    case table = 4
    
    /// Structured JSON output
    case json = 5
}

extension OutputStyle: CustomStringConvertible {
    public var description: String {
        switch self {
        case .default:
            return "Default"
        case .colorful:
            return "Colorful"
        case .minimal:
            return "Minimal"
        case .detailed:
            return "Detailed"
        case .table:
            return "Table"
        case .json:
            return "JSON"
        }
    }
}

