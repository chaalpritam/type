import Foundation
import Data.CharacterModels

struct FountainTemplate {
    
    // MARK: - TV Pilot Templates
    
    static let tvDramaPilot = """
    Title: "PILOT TITLE"
    Credit: Written by
    Author: Your Name
    Episode: 1x01 "Pilot"
    Network: [Network Name]
    Draft date: \(DateFormatter.templateDateFormatter.string(from: Date()))
    
    ===
    
    COLD OPEN
    
    INT. HOSPITAL - EMERGENCY ROOM - NIGHT
    
    Chaos. Monitors beep frantically. DR. SARAH MILLER, 32, works with focused intensity as medical staff rush around her.
    
    DR. MILLER
    (shouting)
    Get me a crash cart! Now!
    
    NURSE JOHNSON
    (responding)
    Coming!
    
    Sarah's hands move with practiced precision. This is her element.
    
    ===
    
    MAIN TITLE
    
    ===
    
    ACT ONE
    
    INT. HOSPITAL - HALLWAY - DAY
    
    Dr. Miller walks down the hallway, exhausted but determined. Her scrubs are wrinkled, her hair disheveled from a long shift.
    
    DR. MILLER
    (to herself)
    Another day, another miracle.
    
    ===
    
    INT. HOSPITAL - DOCTOR'S LOUNGE - DAY
    
    Dr. Miller enters. DR. JAMES WILSON, 45, sits reading a chart. He looks up as she enters.
    
    DR. WILSON
    (looking up)
    Rough night?
    
    DR. MILLER
    (sitting)
    You could say that. Lost two patients.
    
    DR. WILSON
    (sympathetic)
    You can't save everyone, Sarah.
    
    DR. MILLER
    (determined)
    I can try.
    
    ===
    
    ACT TWO
    
    INT. HOSPITAL - OPERATING ROOM - DAY
    
    Dr. Miller and Dr. Wilson work together on a critical patient. The tension is palpable.
    
    DR. MILLER
    (focused)
    Scalpel.
    
    DR. WILSON
    (handing it)
    Here.
    
    ===
    
    ACT THREE
    
    INT. HOSPITAL - HALLWAY - NIGHT
    
    Dr. Miller walks down the same hallway, but now she's smiling. A small victory.
    
    DR. MILLER
    (to herself)
    Today was a good day.
    
    FADE OUT.
    """
    
    static let tvComedyPilot = """
    Title: "FUNNY BUSINESS"
    Credit: Written by
    Author: Your Name
    Episode: 1x01 "Pilot"
    Network: [Network Name]
    Draft date: \(DateFormatter.templateDateFormatter.string(from: Date()))
    
    ===
    
    COLD OPEN
    
    INT. STARTUP OFFICE - DAY
    
    A chaotic open-plan office. JASON CHEN, 28, stands on a desk, trying to rally his team of misfit employees.
    
    JASON
    (enthusiastic)
    Team, today is the day we change the world!
    
    The team looks unimpressed. Coffee cups in hand, they barely glance up.
    
    JASON
    (continuing)
    Our app will revolutionize how people... um... do things!
    
    EMPLOYEE #1
    (deadpan)
    What things?
    
    JASON
    (flustered)
    All the things!
    
    ===
    
    MAIN TITLE
    
    ===
    
    ACT ONE
    
    INT. STARTUP OFFICE - CONFERENCE ROOM - DAY
    
    Jason sits across from VENTURE CAPITALIST, 50s, who looks skeptical.
    
    VENTURE CAPITALIST
    (skeptical)
    So, what exactly does your app do?
    
    JASON
    (nervous)
    Well, it's like Uber, but for... um... everything else!
    
    VENTURE CAPITALIST
    (unimpressed)
    That's not a business model.
    
    ===
    
    ACT TWO
    
    INT. STARTUP OFFICE - DAY
    
    Jason tries to explain his vision to his confused team.
    
    JASON
    (desperate)
    Look, we're going to disrupt the disruption industry!
    
    EMPLOYEE #2
    (confused)
    What does that even mean?
    
    JASON
    (thinking)
    I'm not entirely sure yet.
    
    ===
    
    ACT THREE
    
    INT. STARTUP OFFICE - DAY
    
    Jason realizes the truth about his business.
    
    JASON
    (realizing)
    Maybe we should figure out what we're actually building first.
    
    EMPLOYEE #1
    (relieved)
    Finally, some sense.
    
    FADE OUT.
    """
    
    // MARK: - Feature Film Templates
    
    static let actionFeature = """
    Title: "THE LAST STAND"
    Credit: Written by
    Author: Your Name
    Genre: Action/Thriller
    Draft date: \(DateFormatter.templateDateFormatter.string(from: Date()))
    
    ===
    
    FADE IN:
    
    EXT. URBAN STREET - NIGHT
    
    Rain pours down on a deserted street. JACK STONE, 35, former special forces, walks with purpose. His military bearing is unmistakable.
    
    JACK
    (to himself)
    One more job. Then I'm out.
    
    A car screeches around the corner. Jack's instincts kick in.
    
    ===
    
    INT. ABANDONED WAREHOUSE - NIGHT
    
    Jack enters cautiously, gun drawn. The warehouse is dark, filled with shadows.
    
    JACK
    (calling out)
    I know you're here. Show yourself.
    
    A FIGURE steps from the shadows. It's his old commanding officer, COLONEL RICHARDS.
    
    COLONEL RICHARDS
    (smiling)
    Good to see you, Stone.
    
    JACK
    (suspicious)
    What do you want?
    
    ===
    
    EXT. WAREHOUSE ROOFTOP - NIGHT
    
    Jack and Richards face off. The city lights glow below.
    
    COLONEL RICHARDS
    (serious)
    We need you for one last mission.
    
    JACK
    (firm)
    I'm done with that life.
    
    COLONEL RICHARDS
    (urgent)
    This is different. Lives are at stake.
    
    ===
    
    EXT. CITY STREETS - NIGHT
    
    Jack runs through the streets, pursued by unknown assailants. Gunfire echoes.
    
    JACK
    (to himself)
    Should have known it was never that simple.
    
    FADE OUT.
    """
    
    static let romanticComedy = """
    Title: "LOVE IN THE CITY"
    Credit: Written by
    Author: Your Name
    Genre: Romantic Comedy
    Draft date: \(DateFormatter.templateDateFormatter.string(from: Date()))
    
    ===
    
    FADE IN:
    
    EXT. COFFEE SHOP - MORNING
    
    A charming neighborhood coffee shop. EMMA WILSON, 29, sits at a corner table, typing furiously on her laptop. She's focused, determined.
    
    EMMA
    (to herself)
    Come on, inspiration. Don't fail me now.
    
    A MAN, ALEX THOMPSON, 31, approaches the counter. He's handsome, slightly disheveled, carrying a guitar case.
    
    ===
    
    INT. COFFEE SHOP - MORNING
    
    Emma looks up from her laptop, accidentally making eye contact with Alex. There's a moment. Both look away quickly.
    
    EMMA
    (to herself)
    Focus, Emma. You have a deadline.
    
    Alex sits at a nearby table, tuning his guitar quietly.
    
    ===
    
    EXT. CITY PARK - DAY
    
    Emma walks through the park, lost in thought. She bumps into Alex, literally.
    
    EMMA
    (embarrassed)
    Oh! I'm so sorry!
    
    ALEX
    (smiling)
    No worries. Are you okay?
    
    EMMA
    (flustered)
    Yes, fine. Just... distracted.
    
    ALEX
    (curious)
    Writer's block?
    
    EMMA
    (surprised)
    How did you know?
    
    ===
    
    INT. COFFEE SHOP - EVENING
    
    Emma and Alex sit together, deep in conversation. The coffee shop is closing around them.
    
    EMMA
    (realizing)
    I can't believe we've been talking for hours.
    
    ALEX
    (smiling)
    Time flies when you're having fun.
    
    EMMA
    (nervous)
    This was... nice.
    
    ALEX
    (hopeful)
    Maybe we could do it again sometime?
    
    FADE OUT.
    """
    
    static let sciFiFeature = """
    Title: "BEYOND THE STARS"
    Credit: Written by
    Author: Your Name
    Genre: Science Fiction
    Draft date: \(DateFormatter.templateDateFormatter.string(from: Date()))
    
    ===
    
    FADE IN:
    
    EXT. SPACE - DEEP VOID
    
    The vastness of space. Stars twinkle in the distance. A sleek spacecraft, the AURORA, glides silently through the void.
    
    ===
    
    INT. AURORA - BRIDGE - SPACE
    
    CAPTAIN ELENA VASQUEZ, 34, sits in the command chair, monitoring the ship's systems. Her crew works efficiently around her.
    
    CAPTAIN VASQUEZ
    (to crew)
    Status report.
    
    LIEUTENANT CHEN
    (at station)
    All systems nominal, Captain. We're on course for the Andromeda sector.
    
    CAPTAIN VASQUEZ
    (nodding)
    Good. How long until we reach the anomaly?
    
    LIEUTENANT CHEN
    (checking)
    Approximately three hours.
    
    ===
    
    INT. AURORA - SCIENCE LAB - SPACE
    
    Dr. Marcus Reed, 42, studies strange readings on his console. His face shows concern.
    
    DR. REED
    (worried)
    Captain, you need to see this.
    
    CAPTAIN VASQUEZ
    (entering)
    What is it, Doctor?
    
    DR. REED
    (pointing to screen)
    These readings... they don't match anything in our database.
    
    ===
    
    EXT. SPACE - ANOMALY - SPACE
    
    The Aurora approaches a massive, swirling energy field. It pulses with an otherworldly light.
    
    CAPTAIN VASQUEZ
    (over comm)
    All hands, brace for unknown phenomena.
    
    The ship enters the anomaly. Reality seems to bend around them.
    
    FADE OUT.
    """
    
    // MARK: - Short Film Templates
    
    static let shortDrama = """
    Title: "THE LAST GOODBYE"
    Credit: Written by
    Author: Your Name
    Duration: 10 minutes
    Genre: Drama
    Draft date: \(DateFormatter.templateDateFormatter.string(from: Date()))
    
    ===
    
    FADE IN:
    
    EXT. HOSPITAL GARDEN - DAY
    
    A peaceful garden outside a hospital. MARY, 75, sits on a bench, looking frail but peaceful. Her daughter, LISA, 45, sits beside her.
    
    MARY
    (softly)
    Do you remember when you were little?
    
    LISA
    (smiling)
    Of course, Mom.
    
    MARY
    (remembering)
    You used to chase butterflies in the backyard.
    
    LISA
    (emotional)
    And you'd always tell me to be gentle with them.
    
    ===
    
    EXT. HOSPITAL GARDEN - SAME BENCH - LATER
    
    Mary and Lisa are still there, but now Mary looks weaker.
    
    MARY
    (weakly)
    Lisa, I need to tell you something.
    
    LISA
    (concerned)
    What is it, Mom?
    
    MARY
    (sincere)
    I'm not afraid. I've had a good life.
    
    LISA
    (tearful)
    I'm not ready to say goodbye.
    
    MARY
    (comforting)
    You don't have to. I'll always be with you.
    
    ===
    
    EXT. HOSPITAL GARDEN - SUNSET
    
    Lisa sits alone on the bench. A butterfly lands nearby. She smiles through her tears.
    
    LISA
    (to herself)
    Be gentle with them.
    
    FADE OUT.
    """
    
    static let shortComedy = """
    Title: "THE PERFECT DATE"
    Credit: Written by
    Author: Your Name
    Duration: 8 minutes
    Genre: Comedy
    Draft date: \(DateFormatter.templateDateFormatter.string(from: Date()))
    
    ===
    
    FADE IN:
    
    INT. RESTAURANT - NIGHT
    
    A fancy restaurant. DAVID, 30, sits at a table, nervously adjusting his tie. He's clearly on a first date.
    
    DAVID
    (to himself)
    Don't mess this up. Don't mess this up.
    
    His date, JENNIFER, 28, approaches the table.
    
    JENNIFER
    (smiling)
    Hi, David?
    
    DAVID
    (standing, nervous)
    Yes! Hi! I mean, hello! I'm David!
    
    JENNIFER
    (laughing)
    I know. I just said your name.
    
    ===
    
    INT. RESTAURANT - LATER - NIGHT
    
    David and Jennifer are eating. David is trying too hard to be impressive.
    
    DAVID
    (pretentious)
    I find the existential implications of modern cuisine quite fascinating.
    
    JENNIFER
    (amused)
    You mean you like food?
    
    DAVID
    (embarrassed)
    Yes. I like food.
    
    ===
    
    INT. RESTAURANT - NIGHT
    
    The date is ending. David looks defeated.
    
    DAVID
    (hopeful)
    So, maybe we could do this again sometime?
    
    JENNIFER
    (smiling)
    I'd like that. But maybe somewhere less fancy?
    
    DAVID
    (relieved)
    Pizza?
    
    JENNIFER
    (nodding)
    Perfect.
    
    FADE OUT.
    """
    
    // MARK: - Genre-Specific Templates
    
    static let horrorFeature = """
    Title: "THE SHADOW HOUSE"
    Credit: Written by
    Author: Your Name
    Genre: Horror/Thriller
    Draft date: \(DateFormatter.templateDateFormatter.string(from: Date()))
    
    ===
    
    FADE IN:
    
    EXT. OLD HOUSE - NIGHT
    
    A decrepit Victorian house stands in the moonlight. Windows are dark, paint is peeling. Something feels wrong about this place.
    
    ===
    
    INT. HOUSE - FOYER - NIGHT
    
    SARAH, 25, enters cautiously, flashlight in hand. The floorboards creak under her feet.
    
    SARAH
    (calling out)
    Hello? Anyone here?
    
    Silence. Then a distant sound from upstairs.
    
    ===
    
    INT. HOUSE - UPSTAIRS HALLWAY - NIGHT
    
    Sarah climbs the stairs slowly. The sound grows louder. It's coming from behind a closed door.
    
    SARAH
    (nervous)
    This is not a good idea.
    
    She reaches for the doorknob. It's cold to the touch.
    
    ===
    
    INT. HOUSE - BEDROOM - NIGHT
    
    Sarah opens the door. The room is empty, but the sound continues. It's coming from the walls.
    
    SARAH
    (terrified)
    What is that?
    
    A shadow moves in the corner. Sarah's flashlight flickers.
    
    FADE OUT.
    """
    
    static let mysteryFeature = """
    Title: "THE SILENT WITNESS"
    Credit: Written by
    Author: Your Name
    Genre: Mystery/Thriller
    Draft date: \(DateFormatter.templateDateFormatter.string(from: Date()))
    
    ===
    
    FADE IN:
    
    EXT. CRIME SCENE - NIGHT
    
    Police tape surrounds a luxury apartment building. DETECTIVE MIKE CONNOR, 40, surveys the scene with experienced eyes.
    
    DETECTIVE CONNOR
    (to partner)
    What do we know?
    
    DETECTIVE SANCHEZ
    (reading notes)
    Victim: Jennifer Walsh, 34. Found in her apartment. No signs of forced entry.
    
    ===
    
    INT. APARTMENT - LIVING ROOM - NIGHT
    
    Connor examines the crime scene. Everything looks normal, too normal.
    
    DETECTIVE CONNOR
    (observing)
    Too clean. Someone staged this.
    
    DETECTIVE SANCHEZ
    (curious)
    What makes you say that?
    
    DETECTIVE CONNOR
    (pointing)
    Coffee cup. Still warm, but no lipstick.
    
    ===
    
    INT. POLICE STATION - INTERROGATION ROOM - DAY
    
    Connor interviews a SUSPECT, nervous and sweating.
    
    DETECTIVE CONNOR
    (calm)
    Where were you last night between 8 and 10 PM?
    
    SUSPECT
    (nervous)
    I was... I was at home. Alone.
    
    DETECTIVE CONNOR
    (leaning forward)
    Can anyone verify that?
    
    SUSPECT
    (sweating)
    No. I live alone.
    
    ===
    
    INT. POLICE STATION - OFFICE - NIGHT
    
    Connor reviews evidence, photos spread across his desk. Something catches his eye.
    
    DETECTIVE CONNOR
    (realizing)
    Wait a minute...
    
    He picks up a photo, examining it closely.
    
    FADE OUT.
    """
    
    // MARK: - Original Templates (Updated)
    
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
    
    static func getTemplate(for type: TemplateType) -> String {
        switch type {
        case .default:
            return defaultTemplate
        case .short:
            return shortTemplate
        case .tvDramaPilot:
            return tvDramaPilot
        case .tvComedyPilot:
            return tvComedyPilot
        case .actionFeature:
            return actionFeature
        case .romanticComedy:
            return romanticComedy
        case .sciFiFeature:
            return sciFiFeature
        case .shortDrama:
            return shortDrama
        case .shortComedy:
            return shortComedy
        case .horrorFeature:
            return horrorFeature
        case .mysteryFeature:
            return mysteryFeature
        }
    }
}

enum TemplateType: String, CaseIterable {
    case `default` = "Default"
    case short = "Short"
    case tvDramaPilot = "TV Drama Pilot"
    case tvComedyPilot = "TV Comedy Pilot"
    case actionFeature = "Action Feature"
    case romanticComedy = "Romantic Comedy"
    case sciFiFeature = "Sci-Fi Feature"
    case shortDrama = "Short Drama"
    case shortComedy = "Short Comedy"
    case horrorFeature = "Horror Feature"
    case mysteryFeature = "Mystery Feature"
    
    var description: String {
        switch self {
        case .default:
            return "Basic template with scene structure and formatting examples"
        case .short:
            return "Minimal template for quick starts"
        case .tvDramaPilot:
            return "TV drama pilot with medical setting and character development"
        case .tvComedyPilot:
            return "TV comedy pilot with startup setting and workplace humor"
        case .actionFeature:
            return "Action thriller with former special forces protagonist"
        case .romanticComedy:
            return "Romantic comedy with meet-cute and relationship development"
        case .sciFiFeature:
            return "Science fiction with space exploration and mystery"
        case .shortDrama:
            return "10-minute drama about family and loss"
        case .shortComedy:
            return "8-minute comedy about awkward first dates"
        case .horrorFeature:
            return "Horror thriller with supernatural elements"
        case .mysteryFeature:
            return "Mystery thriller with detective investigation"
        }
    }
    
    var category: TemplateCategory {
        switch self {
        case .default, .short:
            return .basic
        case .tvDramaPilot, .tvComedyPilot:
            return .tvPilots
        case .actionFeature, .romanticComedy, .sciFiFeature, .horrorFeature, .mysteryFeature:
            return .featureFilms
        case .shortDrama, .shortComedy:
            return .shortFilms
        }
    }
}

enum TemplateCategory: String, CaseIterable {
    case basic = "Basic Templates"
    case tvPilots = "TV Pilots"
    case featureFilms = "Feature Films"
    case shortFilms = "Short Films"
    
    var templates: [TemplateType] {
        TemplateType.allCases.filter { $0.category == self }
    }
}

extension DateFormatter {
    static let templateDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
} 