//
//  MainWindow.swift
//  G-Flash
//
//  Created by Sascha Lamprecht on 16.05.20.
//  Copyright © 2020 sl-soft.de. All rights reserved.
//

import Foundation
import LetsMove

class MainWindow: NSViewController {

    @IBOutlet var output_window: NSTextView!
    @IBOutlet weak var content_scroller: NSScrollView!
    
    @IBOutlet weak var save_rom_button: NSButton!
    @IBOutlet weak var write_rom_button: NSButton!
    @IBOutlet weak var get_chip_type_button: NSButton!
    @IBOutlet weak var erase_eeprom_button: NSButton!
    
    @IBOutlet weak var get_chip_type_text: NSTextField!
    
    @IBOutlet weak var devices_pulldown: NSPopUpButton!
    
    @IBOutlet weak var programmer_detect_text: NSTextField!
    @IBOutlet weak var programmer_green_dot: NSImageView!
    @IBOutlet weak var programmer_red_dot: NSImageView!
    @IBOutlet weak var programmer_orange_dot: NSImageView!
    @IBOutlet weak var programmer_progress_wheel: NSProgressIndicator!
    
    let userDesktopDirectory:String = NSHomeDirectory()
    let scriptPath = Bundle.main.path(forResource: "/script/script", ofType: "command")!
    let defaults = UserDefaults.standard
  
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.programmer_detect_text.stringValue = NSLocalizedString("No Device selected", comment: "")
        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height);
    }
    
    @IBAction func list_usb_devices(_ sender: Any) {
        self.syncShellExec(path: self.scriptPath, args: ["_list_usb_devices"])
    }
    
    @IBAction func detect_devices(_ sender: Any) {
        self.programmer_detect_text.stringValue = NSLocalizedString("Searching for Device", comment: "")
        self.programmer_orange_dot.isHidden=true
        self.programmer_green_dot.isHidden=true
        self.programmer_red_dot.isHidden=true
        self.programmer_progress_wheel.isHidden=false
        self.programmer_progress_wheel?.startAnimation(self);
        self.syncShellExec(path: self.scriptPath, args: ["_detect_programmer"])
        programmer_chooser("")
        self.programmer_progress_wheel?.stopAnimation(self);
        self.programmer_progress_wheel.isHidden=true
    }
    
    @IBAction func get_chip_type(_ sender: Any) {
        self.syncShellExec(path: self.scriptPath, args: ["_get_chip_type"])
        let chiptypes_check = UserDefaults.standard.string(forKey: "Chip Types")
        if chiptypes_check == "0" {
            no_chip_found()
            return
        } else if chiptypes_check != "1" {
            multiple_types()
        }

        let force_check = UserDefaults.standard.bool(forKey: "Force Chip Type")
        if force_check == false {
            self.write_rom_button.isEnabled = true
            self.save_rom_button.isEnabled = true
            self.erase_eeprom_button.isEnabled = true
        } else {
            self.write_rom_button.isEnabled = false
            self.save_rom_button.isEnabled = false
            self.erase_eeprom_button.isEnabled = false
        }
    }
    
    @IBAction func input_detection(_ sender: Any) {
        self.write_rom_button.isEnabled = true
        self.save_rom_button.isEnabled = true
        self.erase_eeprom_button.isEnabled = true
    }
    
    
    @IBAction func save_rom(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "Successful")
        let programmer_check = UserDefaults.standard.string(forKey: "Programmer")
        if programmer_check == "0" {
            programmer_not_choosed()
            return
        }
        save_rom(sender: "" as AnyObject)
        self.syncShellExec(path: self.scriptPath, args: ["_save_rom"])
        let success_check = UserDefaults.standard.bool(forKey: "Successful")
        if success_check == true {
            successful()
        } else {
            not_successful()
        }
        
    }

    
    @IBAction func write_rom(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "Successful")
        let programmer_check = UserDefaults.standard.string(forKey: "Programmer")
        if programmer_check == "0" {
            programmer_not_choosed()
            return
        }
        write_rom(sender: "" as AnyObject)
        self.syncShellExec(path: self.scriptPath, args: ["_write_rom"])
        let chip_type_mismatch = UserDefaults.standard.bool(forKey: "Chip Type Mismatch")
        let success_check = UserDefaults.standard.bool(forKey: "Successful")
        if success_check == true {
            successful()
        } else {
            if chip_type_mismatch == true {
                wrong_type_entered()
            } else {
                not_successful()
            }
        }
 
        
        
    }
    
    @IBAction func erase_eeprom(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "Successful")
        let programmer_check = UserDefaults.standard.string(forKey: "Programmer")
        if programmer_check == "0" {
            programmer_not_choosed()
            return
        }
        self.syncShellExec(path: self.scriptPath, args: ["_erase_eeprom"])
        let chip_type_mismatch = UserDefaults.standard.bool(forKey: "Chip Type Mismatch")
        let success_check = UserDefaults.standard.bool(forKey: "Successful")
        if success_check == true {
            successful()
        } else {
            if chip_type_mismatch == true {
                wrong_type_entered()
            } else {
                not_successful()
            }
        }
    }
    
    @IBAction func programmer_chooser(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "Chip Type Mismatch")
        UserDefaults.standard.removeObject(forKey: "Force Chip Type")
        self.programmer_detect_text.stringValue = NSLocalizedString("Checking connected USB Device", comment: "")
        self.programmer_progress_wheel.isHidden = false
        self.programmer_orange_dot.isHidden = true
        self.programmer_red_dot.isHidden = true
        self.programmer_green_dot.isHidden = true
        self.programmer_progress_wheel?.startAnimation(self);
        self.syncShellExec(path: self.scriptPath, args: ["_check_programmer"])
        let programmer_found = UserDefaults.standard.bool(forKey: "Programmer found")
        if programmer_found == true {
            self.programmer_orange_dot.isHidden = true
            self.programmer_red_dot.isHidden = true
            self.programmer_green_dot.isHidden = false
            self.programmer_detect_text.stringValue = NSLocalizedString("Device found", comment: "")
            //self.save_rom_button.isEnabled = true
            //self.write_rom_button.isEnabled = true
            self.get_chip_type_button.isEnabled = true
            //self.erase_eeprom_button.isEnabled = true
        } else {
            self.programmer_orange_dot.isHidden = true
            self.programmer_red_dot.isHidden = false
            self.programmer_green_dot.isHidden = true
            self.programmer_detect_text.stringValue = NSLocalizedString("Device not found", comment: "")
            self.save_rom_button.isEnabled = false
            self.write_rom_button.isEnabled = false
            self.get_chip_type_button.isEnabled = false
            self.erase_eeprom_button.isEnabled = false
        }

        self.programmer_progress_wheel.isHidden = true
        self.programmer_progress_wheel?.stopAnimation(self);
        defaults.synchronize()
    }
    
    
    func syncShellExec(path: String, args: [String] = []) {
        let theme_check = UserDefaults.standard.string(forKey: "System Theme")
        if theme_check == "Dark" {
            output_window.textColor = NSColor.white
        } else {
            output_window.textColor = NSColor.black
        }
        
        let fontsize = CGFloat(14)
        let fontfamily = "Menlo"
        output_window.font = NSFont(name: fontfamily, size: fontsize)
        
        output_window.textStorage?.mutableString.setString("")

        let process            = Process()
        process.launchPath     = "/bin/bash"
        process.arguments      = [path] + args
        let outputPipe         = Pipe()
        let filelHandler       = outputPipe.fileHandleForReading
        process.standardOutput = outputPipe
        
        let group = DispatchGroup()
        group.enter()
        filelHandler.readabilityHandler = { pipe in
            let data = pipe.availableData
            if data.isEmpty { // EOF
                filelHandler.readabilityHandler = nil
                group.leave()
                return
            }
            if let line = String(data: data, encoding: String.Encoding.utf8) {
                DispatchQueue.main.sync {
                    self.output_window.string += line
                    self.output_window.scrollToEndOfDocument(nil)
                }
            } else {
                print("Error decoding data: \(data.base64EncodedString())")
            }
        }
        process.launch() // Start process
        process.waitUntilExit() // Wait for process to terminate.
    }

    
    func save_rom(sender: AnyObject) {
          let dialog = NSSavePanel();
          dialog.title                   = "Choose a Filepath (.bin)";
          dialog.nameFieldStringValue    = "ROM.bin";
          dialog.showsResizeIndicator    = true;
          dialog.showsHiddenFiles        = false;
          dialog.canCreateDirectories    = true;
          //dialog.allowedFileTypes        = ["bin"];
          
          if (dialog.runModal() == NSApplication.ModalResponse.OK) {
              let result = dialog.url // Pathname of the file
              
              if (result != nil) {
                  let path = result!.path
                  let rompath = (path as String)
                  UserDefaults.standard.set(rompath, forKey: "ROM Savepath")
              }
          } else {
              return
          }
      }

    func write_rom(sender: AnyObject) {
          let dialog = NSOpenPanel();
          dialog.title                   = "Choose a ROM File";
          dialog.showsResizeIndicator    = true;
          dialog.showsHiddenFiles        = false;
          dialog.canCreateDirectories    = false;
          dialog.allowedFileTypes        = ["bin"];
          
          if (dialog.runModal() == NSApplication.ModalResponse.OK) {
              let result = dialog.url // Pathname of the file
              
              if (result != nil) {
                  let path = result!.path
                  let rompath = (path as String)
                  UserDefaults.standard.set(rompath, forKey: "ROM Readpath")
              }
          } else {
              return
          }
      }
    
    func programmer_not_choosed (){
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("You did not have selected any Programmer!", comment: "")
        alert.informativeText = NSLocalizedString("Please choose one from the Pulldown Menu and try again.", comment: "")
        alert.alertStyle = .warning
        let Button = NSLocalizedString("Bummer", comment: "")
        alert.addButton(withTitle: Button)
        alert.runModal()
    }
    
    func successful (){
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("Operation done!", comment: "")
        alert.informativeText = NSLocalizedString("No Problems detected.", comment: "")
        alert.alertStyle = .informational
        let Button = NSLocalizedString("Nice", comment: "")
        alert.addButton(withTitle: Button)
        alert.runModal()
    }
    
    func not_successful (){
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("An Error has occured!", comment: "")
        alert.informativeText = NSLocalizedString("Something went wrong. Please try again.", comment: "")
        alert.alertStyle = .warning
        let Button = NSLocalizedString("Bummer", comment: "")
        alert.addButton(withTitle: Button)
        alert.runModal()
    }
 
    func no_chip_found (){
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("Cannot detect any chip!", comment: "")
        alert.informativeText = NSLocalizedString("Make sure the pliers is properly seated on the chip.", comment: "")
        alert.alertStyle = .warning
        let Button = NSLocalizedString("Bummer", comment: "")
        alert.addButton(withTitle: Button)
        alert.runModal()
    }
 
    func multiple_types (){
        UserDefaults.standard.set(true, forKey: "Force Chip Type")
        let chip_types = UserDefaults.standard.string(forKey: "Chip Types")
        self.get_chip_type_text.isHidden = false
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("Multiple chip types found!", comment: "")
        alert.informativeText = NSLocalizedString(chip_types! + " chip types has been recognized. Please enter the correct value in the input field that just appeared. It´s important to press 'Enter' after entering the chip type.", comment: "")
        alert.alertStyle = .warning
        let Button = NSLocalizedString("I understand", comment: "")
        alert.addButton(withTitle: Button)
        alert.runModal()
    }
    
    func wrong_type_entered (){
        //let chip_type = UserDefaults.standard.string(forKey: "Chip Type")
        self.get_chip_type_text.isHidden = false
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("Wrong chip type entered!", comment: "")
        alert.informativeText = NSLocalizedString("No or not the correct chip type was entered in the input field. Please try it again.", comment: "")
        alert.alertStyle = .warning
        let Button = NSLocalizedString("Bummer", comment: "")
        alert.addButton(withTitle: Button)
        alert.runModal()
    }
    
    func erase_confirmation (){
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("Do you want it really?", comment: "")
        alert.informativeText = NSLocalizedString("All content on the chip will be erased!", comment: "")
        alert.alertStyle = .informational
        let Button = NSLocalizedString("Yes", comment: "")
        alert.addButton(withTitle: Button)
        let CancelButtonText = NSLocalizedString("No", comment: "")
        alert.addButton(withTitle: CancelButtonText)
        
        if alert.runModal() != .alertFirstButtonReturn {

            return
        }
    }
    
}