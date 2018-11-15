//
//  DragAndDropTableView+Droppable.swift
//  SwiftDragAndDrop
//
//  Created by Phanha Uy on 11/7/18.
//  Copyright © 2018 Phanha Uy. All rights reserved.
//

import UIKit

// MARK: DropableViewDelegate
extension DragAndDropTableView: DroppableViewDelegate {
    
    public func droppableViewCellRect() -> CGRect? {
        if let index = draggingIndexPath {
            return self.rectForRow(at: index)
        }
        
        return nil
    }
    
    public func droppableView(canDropAt rect : CGRect) -> Bool {
        return (self.indexPathForCellOverlappingRect(rect) != nil) && self.isDroppable
    }
    
    public func droppableView(willMove item: AnyObject, inRect rect: CGRect) -> Void {
        
        // its guaranteed to have a data source
        let dragDropDataSource = self.dataSource as! DragAndDropTableViewDataSource
        
        if let _ = dragDropDataSource.tableView(self, indexPathOf: item) {
            // if data item exists
            return
        }
        
        if let indexPath = self.indexPathForCellOverlappingRect(rect) {
            
            dragDropDataSource.tableView(self, insert: item, atIndexPath: indexPath)
            self.draggingIndexPath = indexPath
            self.insertRows(at: [indexPath], with: .fade)
        }
    }
    
    public func droppableView(didMove item : AnyObject, inRect rect : CGRect) -> Void {
        
        let dragDropDataSource = self.dataSource as! DragAndDropTableViewDataSource // guaranteed to have a ds
        
        if  let existingIndexPath = dragDropDataSource.tableView(self, indexPathOf: item),
            let indexPath = self.indexPathForCellOverlappingRect(rect) {
            
            if indexPath.item != existingIndexPath.item {
                
                dragDropDataSource.tableView(self, moveDataItem: existingIndexPath, to: indexPath)
                self.draggingIndexPath = indexPath
                self.moveRow(at: existingIndexPath, to: indexPath)
            }
        }
        
    }
    
    public func droppableView(autoScroll displayLink: CADisplayLink?, lastAutoScroll timeStamp: CFTimeInterval?, snapshotView rect: CGRect) -> Bool {
        guard let display = displayLink, let lasScrollTimeStamp = timeStamp else {
            return false
        }
        return self.handleDisplayLinkUpdate(autoScroll: display, lastAutoScroll: lasScrollTimeStamp, snapshotView: rect)
    }
    
    public func droppableView(didMoveOut item : AnyObject) -> Void {
        
        guard let dragDropDataSource = self.dataSource as? DragAndDropTableViewDataSource,
            let existngIndexPath = dragDropDataSource.tableView(self, indexPathOf: item) else {
                return
        }
        
        dragDropDataSource.tableView(self, deleteDataItemAt: existngIndexPath)
        self.deleteRows(at: [existngIndexPath], with: .fade)
        
        if let idx = self.draggingIndexPath {
            if let cell = self.cellForRow(at: idx) {
                cell.isHidden = false
            }
        }
        
        self.draggingIndexPath = nil
    }
    
    public func droppableView(dropData item : AnyObject, atRect : CGRect) -> Void {
        
        // show hidden cell
        if  let index = draggingIndexPath,
            let cell = self.cellForRow(at: index), cell.isHidden == true {
            
            cell.alpha = 1
            cell.isHidden = false
            (self.delegate as? DragAndDropTableViewDelegate)?.tableView(self, didDropAt: index)
        }
        
        self.draggingIndexPath = nil
        self.reloadData()
    }
}
