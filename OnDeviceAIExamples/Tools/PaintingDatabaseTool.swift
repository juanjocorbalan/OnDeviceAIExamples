import Foundation
import FoundationModels

/// A tool that searches a local database for famous paintings
struct PaintingDatabaseTool: Tool {
    var name: String { "searchPaintingDatabase" }
    var description: String { "Searches a local database for famous paintings and artworks." }
    
    @Generable
    struct Arguments {
        @Guide(description: "The artist name, painting title, or art style to search for")
        var searchTerm: String
        
        @Guide(description: "The number of paintings to get", .range(1...8))
        var limit: Int
    }
    
    struct Painting {
        let title: String
        let artist: String
        let year: String
        let description: String
        let style: String
        let museum: String
        let dimensions: String
        let medium: String
        let significance: String
    }
    
    private let paintingDatabase: [Painting] = [
        Painting(
            title: "Mona Lisa",
            artist: "Leonardo da Vinci",
            year: "1503-1519",
            description: "The world's most famous portrait, known for the subject's enigmatic smile and da Vinci's sfumato technique",
            style: "Renaissance",
            museum: "Louvre Museum, Paris",
            dimensions: "77 cm × 53 cm (30 in × 21 in)",
            medium: "Oil on poplar panel",
            significance: "Epitome of Renaissance portraiture and the most valuable painting in the world"
        ),
        Painting(
            title: "The Starry Night",
            artist: "Vincent van Gogh",
            year: "1889",
            description: "A swirling night sky over a French village, painted during van Gogh's stay at a psychiatric hospital",
            style: "Post-Impressionism",
            museum: "Museum of Modern Art, New York",
            dimensions: "73.7 cm × 92.1 cm (29 in × 36.25 in)",
            medium: "Oil on canvas",
            significance: "Most recognized work of art and symbol of artistic genius and mental struggle"
        ),
        Painting(
            title: "The Persistence of Memory",
            artist: "Salvador Dalí",
            year: "1931",
            description: "Surrealist masterpiece featuring melting clocks in a dreamscape landscape",
            style: "Surrealism",
            museum: "Museum of Modern Art, New York",
            dimensions: "24 cm × 33 cm (9.5 in × 13 in)",
            medium: "Oil on canvas",
            significance: "Iconic representation of Surrealism and the fluidity of time"
        ),
        Painting(
            title: "Girl with a Pearl Earring",
            artist: "Johannes Vermeer",
            year: "c. 1665",
            description: "Mysterious portrait of a girl wearing an exotic dress and large pearl earring",
            style: "Dutch Golden Age",
            museum: "Mauritshuis, The Hague",
            dimensions: "44.5 cm × 39 cm (17.5 in × 15.4 in)",
            medium: "Oil on canvas",
            significance: "Often called the 'Mona Lisa of the North' for its captivating subject"
        ),
        Painting(
            title: "The Great Wave off Kanagawa",
            artist: "Katsushika Hokusai",
            year: "c. 1831",
            description: "Famous woodblock print depicting a giant wave threatening boats with Mount Fuji in the background",
            style: "Ukiyo-e",
            museum: "Various collections worldwide",
            dimensions: "25.7 cm × 37.9 cm (10.1 in × 14.9 in)",
            medium: "Woodblock print",
            significance: "Most recognizable work of Japanese art and symbol of Japan's artistic heritage"
        ),
        Painting(
            title: "Guernica",
            artist: "Pablo Picasso",
            year: "1937",
            description: "Powerful anti-war painting depicting the horrors of the bombing of Guernica during the Spanish Civil War",
            style: "Cubism",
            museum: "Museo Reina Sofía, Madrid",
            dimensions: "349.3 cm × 776.6 cm (137.4 in × 305.5 in)",
            medium: "Oil on canvas",
            significance: "One of the most powerful anti-war paintings and symbol of peace"
        ),
        Painting(
            title: "The Birth of Venus",
            artist: "Sandro Botticelli",
            year: "c. 1484-1486",
            description: "Mythological scene depicting Venus emerging from the sea as a fully grown woman",
            style: "Renaissance",
            museum: "Uffizi Gallery, Florence",
            dimensions: "172.5 cm × 278.9 cm (67.9 in × 109.6 in)",
            medium: "Tempera on canvas",
            significance: "Masterpiece of Renaissance art and symbol of divine beauty"
        ),
        Painting(
            title: "American Gothic",
            artist: "Grant Wood",
            year: "1930",
            description: "Iconic depiction of a farmer and his daughter standing beside a house with Gothic Revival styling",
            style: "American Regionalism",
            museum: "Art Institute of Chicago",
            dimensions: "78 cm × 65.3 cm (30.7 in × 25.7 in)",
            medium: "Oil on beaverboard",
            significance: "Most parodied American painting and symbol of rural American values"
        ),
    ]
    
    func call(arguments: Arguments) async throws -> ToolOutput {
        // Simulate database query delay
        try await Task.sleep(for: .milliseconds(300))
        
        let searchTerm = arguments.searchTerm.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Enhanced search: check title, artist, style, and description
        let filteredPaintings = paintingDatabase.filter { painting in
            painting.title.lowercased().contains(searchTerm)
            || painting.artist.lowercased().contains(searchTerm)
            || painting.style.lowercased().contains(searchTerm)
            || painting.description.lowercased().contains(searchTerm)
        }
        
        // Sort by relevance (exact title matches first, then artist matches)
        let sortedPaintings = filteredPaintings.sorted { painting1, painting2 in
            let title1ContainsExact = painting1.title.lowercased().contains(searchTerm)
            let title2ContainsExact = painting2.title.lowercased().contains(searchTerm)
            let artist1ContainsExact = painting1.artist.lowercased().contains(searchTerm)
            let artist2ContainsExact = painting2.artist.lowercased().contains(searchTerm)
            
            if title1ContainsExact && !title2ContainsExact { return true }
            if !title1ContainsExact && title2ContainsExact { return false }
            if artist1ContainsExact && !artist2ContainsExact { return true }
            if !artist1ContainsExact && artist2ContainsExact { return false }
            
            return painting1.title < painting2.title
        }
        
        // Limit results
        let paintings = Array(sortedPaintings.prefix(arguments.limit))
        
        let formattedPaintings = paintings.map { painting in
      """
      **\(painting.title)** by \(painting.artist) (\(painting.year))
      \(painting.description)
      Style: \(painting.style) | Medium: \(painting.medium)
      Location: \(painting.museum)
      Dimensions: \(painting.dimensions)
      Significance: \(painting.significance)
      """
        }

        return ToolOutput(GeneratedContent(elements: formattedPaintings))
    }
}
