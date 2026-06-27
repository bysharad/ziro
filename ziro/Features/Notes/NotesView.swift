import SwiftUI
import SwiftData

struct NotesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \NoteModel.updatedAt, order: .reverse) private var allNotes: [NoteModel]
    @State private var searchText = ""
    @State private var selectedNote: NoteModel?
    @State private var showNewNote = false

    var filteredNotes: [NoteModel] {
        let s = searchText.isEmpty ? allNotes : allNotes.filter { $0.title.localizedCaseInsensitiveContains(searchText) || $0.content.localizedCaseInsensitiveContains(searchText) }
        return s.sorted { ($0.isPinned && !$1.isPinned) || ($0.isPinned == $1.isPinned && $0.updatedAt > $1.updatedAt) }
    }

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass").foregroundColor(.secondary).font(.system(size: 14))
                    TextField("Search notes...", text: $searchText).textFieldStyle(.plain)
                    Spacer()
                    Button(action: { showNewNote = true }) { Image(systemName: "plus.circle.fill").font(.title2).foregroundColor(.accentColor) }.buttonStyle(.plain)
                }.padding(.horizontal, 12).padding(.vertical, 10).background(Color(NSColor.controlBackgroundColor))
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(filteredNotes) { note in
                            HStack(spacing: 10) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(note.title).font(.body).fontWeight(.medium).foregroundColor(.primary).lineLimit(1)
                                    if !note.content.isEmpty { Text(String(note.content.prefix(100)) + (note.content.count > 100 ? "..." : "")).font(.caption).foregroundColor(.secondary).lineLimit(2) }
                                }
                                Spacer()
                                Button(action: { note.isPinned.toggle() }) { Image(systemName: note.isPinned ? "pin.fill" : "pin").font(.caption).foregroundColor(.secondary) }.buttonStyle(.plain)
                            }.padding(.horizontal, 10).padding(.vertical, 8)
                                .background(RoundedRectangle(cornerRadius: 6).fill(selectedNote?.id == note.id ? Color.accentColor.opacity(0.15) : .clear))
                                .onTapGesture { selectedNote = note }
                                .contextMenu { Button("Delete", role: .destructive) { modelContext.delete(note) } }
                        }
                    }.padding(.horizontal, 8).padding(.vertical, 4)
                }
            }.frame(minWidth: 280).background(VisualEffectView())
            Divider()
            if let note = selectedNote {
                VStack(spacing: 0) {
                    HStack {
                        TextField("Note title", text: Binding(get: { note.title }, set: { note.title = $0 })).font(.system(.title3, design: .rounded, weight: .semibold))
                        Spacer()
                        Button("Delete", role: .destructive) { modelContext.delete(note); selectedNote = nil }.font(.caption)
                    }.padding(.horizontal).padding(.vertical, 8).background(Color(NSColor.controlBackgroundColor))
                    Divider()
                    TextEditor(text: Binding(get: { note.content }, set: { note.content = $0; note.updatedAt = Date() })).font(.system(.body)).background(Color.clear)
                }.frame(minWidth: 400).background(VisualEffectView())
            } else {
                VStack(spacing: 20) { Image(systemName: "note.text").font(.system(size: 64)).foregroundColor(.secondary).opacity(0.3); Text("Select a note or create a new one").font(.title3).foregroundColor(.secondary).multilineTextAlignment(.center) }.frame(maxWidth: .infinity, maxHeight: .infinity).background(VisualEffectView())
            }
        }.sheet(isPresented: $showNewNote) { NewNoteView() }
    }
}

struct NewNoteView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("New Note").font(.title2).fontWeight(.semibold)
            TextField("Note title", text: $title).textFieldStyle(.roundedBorder)
            HStack(spacing: 16) {
                Button("Cancel") { dismiss() }.buttonStyle(.bordered)
                Button("Create") { modelContext.insert(NoteModel(title: title)); dismiss() }.buttonStyle(.borderedProminent).disabled(title.isEmpty)
            }
        }.padding().frame(width: 300, height: 160)
    }
}
