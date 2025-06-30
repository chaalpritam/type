import Foundation

struct FountainTemplate {
    
    static let defaultTemplate = """
    Title: Your Screenplay Title
    Credit: Written by
    Author: Your Name
    Draft date: \(DateFormatter.templateDateFormatter.string(from: Date()))
    
    ===
    
    FADE IN:
    
    INT. LOCATION - DAY
    
    A brief description of the scene. Keep action lines concise and visual.
    
    CHARACTER NAME
    (character direction)
    Dialogue goes here. Keep it natural and engaging.
    
    ANOTHER CHARACTER
    Another line of dialogue that responds to the first character.
    
    CHARACTER NAME
    (continuing)
    More dialogue that flows naturally from the conversation.
    
    ===
    
    EXT. ANOTHER LOCATION - NIGHT
    
    Different scene description. Show, don't tell.
    
    CHARACTER NAME
    (emotion or action)
    More dialogue that reveals character and advances the plot.
    
    ===
    
    INT. THIRD LOCATION - DAY
    
    Final scene description. Each scene should move the story forward.
    
    CHARACTER NAME
    The final piece of dialogue that concludes this sequence.
    
    FADE OUT.
    
    ===
    
    FADE IN:
    
    INT. NEW SCENE - DAY
    
    This is where your story begins. Replace this template with your actual screenplay content.
    
    Remember:
    • Scene headings: INT./EXT. LOCATION - TIME
    • Character names in CAPS
    • Parentheticals for character direction
    • Action lines describe what we see
    • Dialogue reveals character and advances plot
    
    Happy writing!
    """
    
    static let shortTemplate = """
    Title: Untitled Screenplay
    Credit: Written by
    Author: Your Name
    
    ===
    
    FADE IN:
    
    INT. LOCATION - DAY
    
    Scene description goes here.
    
    CHARACTER NAME
    (character direction)
    Dialogue goes here.
    
    FADE OUT.
    """
    
    static let featureTemplate = """
    Title: Feature Film Title
    Credit: Written by
    Author: Your Name
    Contact: your.email@example.com
    Draft date: \(DateFormatter.templateDateFormatter.string(from: Date()))
    
    ===
    
    FADE IN:
    
    EXT. CITY STREET - DAY
    
    A bustling urban landscape. Cars honk, people rush by. The camera finds our protagonist.
    
    JOHN DOE
    (to himself)
    Today's the day everything changes.
    
    He takes a deep breath and steps forward into the crowd.
    
    ===
    
    INT. OFFICE BUILDING - LOBBY - DAY
    
    John enters through revolving doors. The lobby is modern, sterile.
    
    RECEPTIONIST
    (professional)
    Can I help you?
    
    JOHN DOE
    I have an appointment with Mr. Smith.
    
    RECEPTIONIST
    (checking computer)
    Name?
    
    JOHN DOE
    John Doe. 2:00 PM.
    
    ===
    
    INT. OFFICE - CONFERENCE ROOM - DAY
    
    John sits across from MR. SMITH, a middle-aged executive.
    
    MR. SMITH
    (reviewing papers)
    Your proposal is... interesting.
    
    JOHN DOE
    (hopeful)
    I think it could revolutionize the industry.
    
    MR. SMITH
    (skeptical)
    That's what they all say.
    
    ===
    
    EXT. OFFICE BUILDING - DAY
    
    John exits the building, dejected. He looks up at the sky.
    
    JOHN DOE
    (to himself)
    Back to the drawing board.
    
    He walks away, but there's determination in his step.
    
    FADE OUT.
    """
    
    static let tvEpisodeTemplate = """
    Title: "Episode Title"
    Credit: Written by
    Author: Your Name
    Episode: 1x01 "Pilot"
    Draft date: \(DateFormatter.templateDateFormatter.string(from: Date()))
    
    ===
    
    COLD OPEN
    
    INT. HOSPITAL - EMERGENCY ROOM - NIGHT
    
    Chaos. Doctors and nurses rush around. DR. SARAH MILLER, 30s, works frantically.
    
    DR. MILLER
    (shouting)
    Get me a crash cart!
    
    NURSE
    (responding)
    Coming!
    
    ===
    
    MAIN TITLE
    
    ===
    
    ACT ONE
    
    INT. HOSPITAL - HALLWAY - DAY
    
    Dr. Miller walks down the hallway, exhausted but determined.
    
    DR. MILLER
    (to herself)
    Another day, another miracle.
    
    ===
    
    INT. HOSPITAL - DOCTOR'S LOUNGE - DAY
    
    Dr. Miller enters. DR. JAMES WILSON, 40s, sits reading a chart.
    
    DR. WILSON
    (looking up)
    Rough night?
    
    DR. MILLER
    (sitting)
    You could say that.
    
    ===
    
    ACT TWO
    
    INT. HOSPITAL - OPERATING ROOM - DAY
    
    Dr. Miller and Dr. Wilson work together on a patient.
    
    DR. MILLER
    (focused)
    Scalpel.
    
    DR. WILSON
    (handing it)
    Here.
    
    ===
    
    ACT THREE
    
    INT. HOSPITAL - HALLWAY - NIGHT
    
    Dr. Miller walks down the same hallway, but now she's smiling.
    
    DR. MILLER
    (to herself)
    Today was a good day.
    
    FADE OUT.
    """
    
    static let shortFilmTemplate = """
    Title: Short Film Title
    Credit: Written by
    Author: Your Name
    Duration: 10 minutes
    Draft date: \(DateFormatter.templateDateFormatter.string(from: Date()))
    
    ===
    
    FADE IN:
    
    EXT. PARK - DAY
    
    A quiet park bench. Leaves fall gently. JANE, 25, sits alone.
    
    JANE
    (to herself)
    Sometimes the smallest moments change everything.
    
    A MAN, 30, approaches hesitantly.
    
    MAN
    (nervous)
    Excuse me, is this seat taken?
    
    JANE
    (smiling)
    No, please.
    
    ===
    
    EXT. PARK - SAME BENCH - LATER
    
    Jane and the man are deep in conversation, laughing.
    
    JANE
    (laughing)
    That's the funniest thing I've heard all day.
    
    MAN
    (smiling)
    I'm glad I could make you laugh.
    
    ===
    
    EXT. PARK - SAME BENCH - SUNSET
    
    They're still there, watching the sunset together.
    
    JANE
    (content)
    Thank you for today.
    
    MAN
    (sincere)
    The pleasure was mine.
    
    They hold hands as the sun sets.
    
    FADE OUT.
    """
    
    static func getTemplate(for type: TemplateType) -> String {
        switch type {
        case .default:
            return defaultTemplate
        case .short:
            return shortTemplate
        case .feature:
            return featureTemplate
        case .tvEpisode:
            return tvEpisodeTemplate
        case .shortFilm:
            return shortFilmTemplate
        }
    }
}

enum TemplateType: String, CaseIterable {
    case `default` = "Default"
    case short = "Short"
    case feature = "Feature Film"
    case tvEpisode = "TV Episode"
    case shortFilm = "Short Film"
    
    var description: String {
        switch self {
        case .default:
            return "Basic template with scene structure and formatting examples"
        case .short:
            return "Minimal template for quick starts"
        case .feature:
            return "Full feature film template with multiple scenes"
        case .tvEpisode:
            return "TV episode template with acts and cold open"
        case .shortFilm:
            return "Short film template for 10-minute stories"
        }
    }
}

extension DateFormatter {
    static let templateDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
} 