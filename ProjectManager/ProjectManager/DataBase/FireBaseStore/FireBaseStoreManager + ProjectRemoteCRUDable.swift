//
//  FireBaseStoreManager + ProjectCRUDable.swift
//  ProjectManager
//
//  Created by 써니쿠키 on 2023/01/24.
//

import Foundation
import Firebase

final class FireBaseStoreManager {
    
    let fireStore = Firestore.firestore()
    let collectionName: String = "ProjectCollection"
    
    func changeToFields(from projectViewModel: ProjectViewModel) -> [String: Any] {
        let project = projectViewModel.project
        let state = projectViewModel.state
        
        let fields = ["title": project.title ?? "",
                      "detail": project.detail ?? "",
                      "date": Timestamp(date: project.date),
                      "state": state.rawValue]
        as [String: Any]
        
        return fields
    }
    
    func changeToProjectViewModel(from document: QueryDocumentSnapshot) -> ProjectViewModel {
        let fields = document.data()
        
        let title = fields["title"] as? String ?? ""
        let detail = fields["detail"] as? String ?? ""
        let stateRawValue = (fields["stae"] as? Int) ?? 0
        let state = ProjectState(rawValue: stateRawValue) ?? .todo
        let uuid = UUID(uuidString: document.documentID) ?? UUID()
        let date = (fields["date"] as? Timestamp)?.dateValue() ?? Date()
        
        let project = Project(title: title, detail: detail, date: date, uuid: uuid)
        let projectViewModel = ProjectViewModel(project: project, state: state)
        
        return projectViewModel
    }
}

extension FireBaseStoreManager: ProjectRemoteCRUDable {
        
    func create(_ data: ProjectViewModel) {
        let projectUuid = data.project.uuid
        
        fireStore
            .collection(collectionName)
            .document(projectUuid.uuidString)
            .setData(changeToFields(from: data))
    }
    
    func read(completion: @escaping (Result<[ProjectViewModel], Error>) -> Void) {
        fireStore.collection(collectionName).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            var projectViewModels: [ProjectViewModel] = []
            
            documents.forEach { [weak self] document in
                guard let self = self else { return }
                
                let projectViewModel = self.changeToProjectViewModel(from: document)
                projectViewModels.append(projectViewModel)
            }
            
            completion(.success(projectViewModels))
        }
    }
    
    func update(_ data: ProjectViewModel) {
        let projectUuid = data.project.uuid
        
        fireStore
            .collection(collectionName)
            .document(projectUuid.uuidString)
            .updateData(changeToFields(from: data))
    }
    
    func delete(_ data: ProjectViewModel) {
        let project = data.project
        
        fireStore
            .collection(collectionName)
            .document(project.uuid.uuidString)
            .delete()
    }
    
    func deleteAll() {
        read { result in
            switch result {
            case .success(let projectViewModels):
                projectViewModels.forEach { projectViewModel in
                    self.delete(projectViewModel)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }
    
    func updateAfterNetworkConnection(projectViewModels: [ProjectViewModel]) {
        projectViewModels.forEach { projectViewModel in
            update(projectViewModel)
        }
    }
}
