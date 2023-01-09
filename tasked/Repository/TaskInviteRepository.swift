//
//  TaskInviteRepository.swift
//  tasked
//
//  Created by Darko Skerlevski on 7.1.23.
//

import Foundation
import FirebaseFirestore
import Firebase


class TaskInviteRepository: ObservableObject {
    
    let db = Firestore.firestore()
    let auth = Auth.auth()
    
    @Published var invites = [CustomInvite]()
    
    init(){
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        db.settings = settings
        loadData()
    }
    
    func loadData() {
        db.collection("invites").addSnapshotListener { (querySnapshot, error) in
            if let querySnapshot = querySnapshot {
                DispatchQueue.main.async {
                    let invitesForUser = querySnapshot.documents.filter({ d in
                        d["forUserEmail"] as? String == self.auth.currentUser?.email
                    })
                    self.invites = invitesForUser.map { d in
                        return CustomInvite(id: d.documentID, forTaskID: d["forTaskID"] as? String ?? "", forTaskTitle: d["forTaskTitle"] as? String ?? "", forUserEmail: d["forUserEmail"] as? String ?? "", fromEmail: d["fromEmail"] as? String ?? "", fromName: d["fromName"] as? String ?? "")
                    }
                }
            }
        }
    }
    
    func addInvite(_ invite: CustomInvite) {
        do {
            let _ = try db.collection("invites").addDocument(data: ["forTaskID" : invite.forTaskID, "forTaskTitle" : invite.forTaskTitle, "forUserEmail" : invite.forUserEmail, "fromEmail" : invite.fromEmail, "fromName" : invite.fromName])
        }
        catch {
            fatalError("Unable to encode invite: \(error.localizedDescription)")
        }
    }
    
    func removeInvite(_ invite: CustomInvite) {
        do {
            let _ = try db.collection("invites").document(invite.id).delete()
        }
        catch {
            fatalError("Unable to encode invite: \(error.localizedDescription)")
        }
        
    }
}
