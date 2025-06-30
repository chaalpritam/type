import SwiftUI

// MARK: - Timeline Main View
struct TimelineView: View {
    @ObservedObject var timelineDatabase: TimelineDatabase
    @GestureState private var dragOffset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        VStack(spacing: 0) {
            TimelineHeaderView(statistics: timelineDatabase.statistics)
            
            GeometryReader { geometry in
                ScrollView([.horizontal, .vertical], showsIndicators: true) {
                    ZStack(alignment: .topLeading) {
                        // Timeline axis
                        TimelineAxisView(
                            acts: timelineDatabase.timeline.acts,
                            width: geometry.size.width * max(1, timelineDatabase.zoomLevel),
                            height: 80
                        )
                        .offset(x: timelineDatabase.panOffset.x + dragOffset.width, y: timelineDatabase.panOffset.y + dragOffset.height)
                        
                        // Timeline scenes
                        TimelineScenesView(
                            scenes: timelineDatabase.timeline.scenes,
                            beats: timelineDatabase.timeline.storyBeats,
                            acts: timelineDatabase.timeline.acts,
                            zoomLevel: timelineDatabase.zoomLevel,
                            selectedElement: $timelineDatabase.selectedElement
                        )
                        .offset(x: timelineDatabase.panOffset.x + dragOffset.width, y: timelineDatabase.panOffset.y + dragOffset.height + 80)
                    }
                    .frame(width: geometry.size.width * max(1, timelineDatabase.zoomLevel), height: 400)
                    .background(Color(.systemGray6))
                    .gesture(
                        DragGesture()
                            .updating($dragOffset) { value, state, _ in
                                state = value.translation
                            }
                            .onEnded { value in
                                timelineDatabase.panOffset.x += value.translation.width
                                timelineDatabase.panOffset.y += value.translation.height
                            }
                    )
                }
            }
            .frame(height: 480)
            
            TimelineControlsView(timelineDatabase: timelineDatabase)
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - Timeline Header
struct TimelineHeaderView: View {
    let statistics: TimelineStatistics
    var body: some View {
        HStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Story Timeline")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("\(statistics.totalScenes) scenes • \(statistics.totalActs) acts • \(statistics.totalBeats) beats")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            HStack(spacing: 16) {
                StatCard(title: "Acts", value: "\(statistics.totalActs)", icon: "rectangle.split.3x1")
                StatCard(title: "Beats", value: "\(statistics.totalBeats)", icon: "waveform.path.ecg")
                StatCard(title: "Milestones", value: "\(statistics.totalMilestones)", icon: "flag")
            }
        }
        .padding()
        .background(Color(.systemGray5))
    }
}

// MARK: - Timeline Axis View
struct TimelineAxisView: View {
    let acts: [StoryAct]
    let width: CGFloat
    let height: CGFloat
    var body: some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .fill(Color(.systemGray4))
                .frame(width: width, height: height)
            HStack(spacing: 0) {
                ForEach(acts) { act in
                    VStack {
                        Text(act.name)
                            .font(.headline)
                            .foregroundColor(act.color.color)
                        Spacer()
                        Rectangle()
                            .fill(act.color.color)
                            .frame(height: 4)
                    }
                    .frame(width: width / CGFloat(max(1, acts.count)), height: height)
                }
            }
        }
    }
}

// MARK: - Timeline Scenes View
struct TimelineScenesView: View {
    let scenes: [TimelineScene]
    let beats: [StoryBeat]
    let acts: [StoryAct]
    let zoomLevel: Double
    @Binding var selectedElement: TimelineElement?
    
    var body: some View {
        ZStack {
            // Beat markers
            ForEach(beats) { beat in
                TimelineBeatMarkerView(beat: beat, acts: acts, zoomLevel: zoomLevel)
            }
            // Scene cards
            ForEach(scenes) { timelineScene in
                TimelineSceneCardView(
                    timelineScene: timelineScene,
                    acts: acts,
                    zoomLevel: zoomLevel,
                    isSelected: selectedElement?.id == timelineScene.id
                )
                .onTapGesture {
                    selectedElement = timelineScene
                }
            }
        }
    }
}

// MARK: - Timeline Scene Card View
struct TimelineSceneCardView: View {
    let timelineScene: TimelineScene
    let acts: [StoryAct]
    let zoomLevel: Double
    let isSelected: Bool
    
    var body: some View {
        let actIndex = max(0, timelineScene.position.act - 1)
        let actCount = max(1, acts.count)
        let actWidth: CGFloat = 220 * CGFloat(zoomLevel)
        let x = CGFloat(actIndex) * actWidth + CGFloat(timelineScene.position.scene - 1) * 60 * CGFloat(zoomLevel)
        let y: CGFloat = 0
        
        VStack(alignment: .leading, spacing: 4) {
            Text(timelineScene.scene.heading)
                .font(.headline)
                .lineLimit(1)
            HStack(spacing: 8) {
                Text("Scene \(timelineScene.scene.sceneNumber ?? 0)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(timelineScene.storyFunction.rawValue)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            HStack(spacing: 8) {
                Text(timelineScene.scene.location)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(timelineScene.scene.timeOfDay.rawValue)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(8)
        .background(isSelected ? Color.accentColor.opacity(0.2) : timelineScene.customColor?.color.opacity(0.15) ?? timelineScene.scene.color.color.opacity(0.15))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
        )
        .position(x: x + 80, y: y + 40)
        .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Timeline Beat Marker View
struct TimelineBeatMarkerView: View {
    let beat: StoryBeat
    let acts: [StoryAct]
    let zoomLevel: Double
    
    var body: some View {
        let actIndex = max(0, beat.position.act - 1)
        let actWidth: CGFloat = 220 * CGFloat(zoomLevel)
        let x = CGFloat(actIndex) * actWidth + CGFloat(beat.position.scene - 1) * 60 * CGFloat(zoomLevel) + CGFloat(beat.position.percentage) * actWidth
        let y: CGFloat = 0
        
        VStack(spacing: 2) {
            Image(systemName: "waveform.path.ecg")
                .foregroundColor(.purple)
            Text(beat.name)
                .font(.caption2)
                .foregroundColor(.purple)
        }
        .position(x: x + 80, y: y + 10)
    }
}

// MARK: - Timeline Controls View
struct TimelineControlsView: View {
    @ObservedObject var timelineDatabase: TimelineDatabase
    var body: some View {
        HStack(spacing: 16) {
            Button(action: {
                withAnimation { timelineDatabase.zoomLevel = max(0.5, timelineDatabase.zoomLevel - 0.2) }
            }) {
                Image(systemName: "minus.magnifyingglass")
            }
            Button(action: {
                withAnimation { timelineDatabase.zoomLevel = min(3.0, timelineDatabase.zoomLevel + 0.2) }
            }) {
                Image(systemName: "plus.magnifyingglass")
            }
            Divider().frame(height: 24)
            Button(action: {
                withAnimation { timelineDatabase.panOffset = .zero }
            }) {
                Image(systemName: "arrow.up.left.and.down.right.magnifyingglass")
            }
            Divider().frame(height: 24)
            Toggle("Connections", isOn: $timelineDatabase.showConnections)
                .toggleStyle(.switch)
            Toggle("Notes", isOn: $timelineDatabase.showNotes)
                .toggleStyle(.switch)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray5))
    }
} 