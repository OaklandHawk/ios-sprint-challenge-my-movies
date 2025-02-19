//
//  MyMoviesTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import CoreData

class MyMoviesTableViewController: UITableViewController {
	
	var movieController = MovieController()
	
	lazy var movieResultsController: NSFetchedResultsController<Movie> = {
		
		let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "hasWatched", ascending: true)]
		
		let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
											 managedObjectContext: CoreDataStack.shared.mainContext,
											 sectionNameKeyPath: "hasWatched",
											 cacheName: nil)
		
		frc.delegate = self
		
		do {
			try frc.performFetch()
		} catch {
			fatalError("Error performing fetch for frc: \(error)")
		}
		return frc
	}()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		tableView.reloadData()
	}

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return movieResultsController.sections?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return movieResultsController.sections?[section].numberOfObjects ?? 0
    }

	// TODO: Create cell for this
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyMovieCell", for: indexPath) as? MyMovieTableViewCell else { return UITableViewCell() }

//		let movie = movieResultsController.object(at: indexPath)
		
		cell.movieController = movieController
		cell.movie = movieResultsController.object(at: indexPath)
		
        return cell
    }
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		
		guard let sectionInfo = movieResultsController.sections?[section] else { return nil }
		
		return sectionInfo.name.capitalized
	}

	
    // Override to support editing the table view.
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		let movie = movieResultsController.object(at: indexPath)

        if editingStyle == .delete {
            movieController.delete(movie: movie)
        }
    }
	
}

extension MyMoviesTableViewController: MyMovieCellDelegate {
	
	func watchStatusToggle(for movie: Movie) {
		movie.managedObjectContext?.performAndWait {
			movie.hasWatched.toggle()
		}
		movieController.updateTheMovie(movie: movie)
	}
}


extension MyMoviesTableViewController: NSFetchedResultsControllerDelegate {
	
	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.beginUpdates()
	}
	
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.endUpdates()
	}
	
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
					didChange anObject: Any,
					at indexPath: IndexPath?,
					for type: NSFetchedResultsChangeType,
					newIndexPath: IndexPath?) {
		switch type {
		case .insert:
			guard let newIndexPath = newIndexPath else { return }
			tableView.insertRows(at: [newIndexPath], with: .automatic)
		case .delete:
			guard let indexPath = indexPath else { return }
			tableView.deleteRows(at: [indexPath], with: .automatic)
		case .move:
			guard let indexPath = indexPath,
				let newIndexPath = newIndexPath else { return }
			tableView.moveRow(at: indexPath, to: newIndexPath)
		case .update:
			guard let indexPath = indexPath else { return }
			tableView.reloadRows(at: [indexPath], with: .automatic)
		@unknown default:
			return
		}
	}
	
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
					didChange sectionInfo: NSFetchedResultsSectionInfo,
					atSectionIndex sectionIndex: Int,
					for type: NSFetchedResultsChangeType) {
		
		let sectionSet = IndexSet(integer: sectionIndex)
		
		switch type {
		case .insert:
			tableView.insertSections(sectionSet, with: .automatic)
		case .delete:
			tableView.deleteSections(sectionSet, with: .automatic)
		default:
			return
		}
	}
}
