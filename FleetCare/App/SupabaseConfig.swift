import Foundation
import Supabase

enum SupabaseConfig {
    // This is your actual project URL based on your Project ID
    static let projectURL = URL(string: "https://ycxdwegfeizlorpdinyu.supabase.co")!
    
    // ⚠️ PASTE YOUR ANON PUBLIC KEY INSIDE THE QUOTES BELOW ⚠️
    static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InljeGR3ZWdmZWl6bG9ycGRpbnl1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIzNzc1MjEsImV4cCI6MjA5Nzk1MzUyMX0.tTZUkvskf2QT18Z0Mv0Y0jR69xmJWl4Dg8g7lPCKwdg"
    
    static let client = SupabaseClient(
        supabaseURL: projectURL,
        supabaseKey: anonKey,
        options: SupabaseClientOptions(
            auth: SupabaseClientOptions.AuthOptions(
                emitLocalSessionAsInitialSession: true
            )
        )
    )
}
