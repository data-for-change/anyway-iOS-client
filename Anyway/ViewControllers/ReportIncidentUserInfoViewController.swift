//
//  ReportIncidentUserInfoViewController.swift
//  Anyway
//
//  Created by Yigal Omer on 03/10/2019.
//  Copyright © 2019 Hasadna. All rights reserved.
//

import UIKit
import Eureka

protocol ReportIncidentUserInfoViewControllerDelegate: class {

    func didFinishUserInfo()
    func didCancelUserInfo()
}

class ReportIncidentUserInfoViewController: FormViewController {

    private var api: AnywayAPIImpl!
    private var sendToMonicipality: Bool?
    private var firstName: String?
    private var lastName: String?
    private var id: String?
    private var email: String?
    private var phoneNumber: String?
    var incidentData: Incident!
    weak var delegate: ReportIncidentUserInfoViewControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.navigationController?.isNavigationBarHidden = false
        let sessionConfiguration: URLSessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = Config.TIMEOUT_INTERVAL_FOR_REQUEST
        self.api = AnywayAPIImpl(sessionConfiguration: sessionConfiguration)
        
        setupNavigationBar()
        setupForm()
    }
    
    internal func setupForm() {
        
        navigationOptions = RowNavigationOptions.Disabled
        //form += [userSection()]
        addForm()
    }
      
      
    private func addUserInfoToIncidentData() {
        incidentData.send_to_monicipality = sendToMonicipality ?? false
        self.incidentData.fist_name = self.firstName
        self.incidentData.id = self.lastName
        self.incidentData.fist_name = self.id
        self.incidentData.email = self.email
        self.incidentData.phone_number = self.phoneNumber
    }
    
    private func sendButtonTapped() {
        
        addUserInfoToIncidentData()
        
        self.api.reportIncident(incidentData!) { (result: Bool) in
           
            //self.hideHUD()
            print("finished reportIncident. result = \(result)")
            
            self.show(error: "הנתונים נשלחו בהצלחה")
           
//            self.delegate?.didFinishUserInfo()
        }
        
        
        
        // startReportIncidentUserInfoVC(incidentData: incidentData)
        

    }
      

    
    private func addForm() {// -> Section {
        
        
        // return Section("פרטים אישיים")
        form +++ Section("")
            <<< SwitchRow("report") {
                $0.title = "דווח לרשות העירונית"
                $0.value = false
            }.onChange{ [weak self] row in
                guard let sendToMonicipality = row.value else {return}
                self?.sendToMonicipality = sendToMonicipality
                
                self?.setAllCellTextColorAccordingToSwitch()
            }
            
            <<< TextRow("firstName"){ row in
                row.title = "שם פרטי"
                row.add(rule: RuleRequired())
                //row.placeholder = "הכנס שם פרטי  "
            }.onChange{ [weak self] row in
                guard let firstName = row.value else {return}
                self?.firstName = firstName
            }
            
            <<< TextRow("lastName"){row in
                row.title = "שם משפחה"
                row.add(rule: RuleRequired())
                // $0.placeholder = "הכנס שם משפחה  "
            }.onChange{ [weak self] row in
                guard let lastName = row.value else {return}
                self?.lastName = lastName
            }
            
            <<< PhoneRow("id"){
                $0.title = "תעודת זהות"
                $0.add(rule: RuleRequired())
                //$0.placeholder = "הכנס תעודת זהות"
            }.onChange{ [weak self] row in
                guard let id = row.value else {return}
                self?.id = id
            }
            
            <<< EmailRow("email"){
                $0.title = "דואר אלקטרוני"
                $0.add(rule: RuleRequired())
                //$0.placeholder = "הכנס דואר אלטרוני  "
            }.onChange{ [weak self] row in
                guard let email = row.value else {return}
                self?.email = email
            }
            
            <<< PhoneRow("phone"){
                $0.title = "מספר טלפון"
                $0.add(rule: RuleRequired())
                //$0.placeholder = "הכנס מספר טלפון"
            }.onChange{ [weak self] row in
                guard let phoneNumber = row.value else {return}
                self?.phoneNumber = phoneNumber
            }
            

            //+++ Section("שלח את פרטי המפגע") { section in
            // Button section
            +++ Section("") { section in
                section.header?.height = { 50 }
                section.footer?.height = { 40 }
            }
            
            <<< ButtonRow(){ row in
                row.title = "שלח"
            
                row.cellUpdate { cell, row in
                    cell.textLabel?.textColor = UIColor.white
                    cell.backgroundColor =  UIColor.init(hexString: "3764BC")
                    print ( " in cellUpdate -   row.isDisabled  = \( row.isDisabled )" )
                    cell.backgroundColor = row.isDisabled ? UIColor.lightGray : UIColor.init(hexString: "3764BC")

                }
                row.disabled = Condition.function(
                    form.allRows.compactMap { $0.tag }, // All row tags
                    { _ in
                        let count = row.section?.form?.validate().count
                        return self.isFormValid(count)
                })
                
                row.onCellSelection { [weak self] (cell, row) in
                   // if row.section?.form?.validate().count == 0{
                       // print("form is valid")
                    //let count = row.section?.form?.validate().count
                    if !(row.isDisabled){
                        self?.sendButtonTapped()
                    }
//                    }
//                    else{
//                        print("form is NOT valid")
//                        //self?.show(error: "שדות חסרים")
//                    }
                }
                
        }
    }
    
    
    fileprivate func isFormValid(_ count: Int?) -> Bool {
        // button is enabled when sendToMonicipality is false
        if  !(self.sendToMonicipality ?? false) {
            return false
            // or if sendToMonicipality is true  and all other rows are valid - not empty
        }else  if  count != 0 &&  self.sendToMonicipality ?? false {
            return true
        }
        else{
            return false
        }
    }
    
    private func setAllCellTextColorAccordingToSwitch() {
        
        let rowFirstName: TextRow? = self.form.rowBy(tag: "firstName")
        let rowLastName: TextRow? = self.form.rowBy(tag: "lastName")
        let rowid: PhoneRow? = self.form.rowBy(tag: "id")
        let rowEmail: EmailRow? = self.form.rowBy(tag: "email")
        let rowPhone: PhoneRow? = self.form.rowBy(tag: "phone")
        
        if self.sendToMonicipality ?? false {
            rowFirstName?.cell.titleLabel?.textColor = .red
            rowLastName?.cell.titleLabel?.textColor = .red
            rowid?.cell.titleLabel?.textColor = .red
            rowEmail?.cell.titleLabel?.textColor = .red
            rowPhone?.cell.titleLabel?.textColor = .red
        }
        else{
            rowFirstName?.cell.titleLabel?.textColor = .black
            rowLastName?.cell.titleLabel?.textColor = .black
            rowid?.cell.titleLabel?.textColor = .black
            rowEmail?.cell.titleLabel?.textColor = .black
            rowEmail?.cell.titleLabel?.textColor = .black
            rowPhone?.cell.titleLabel?.textColor = .black
        }
    }
    
    
    
    func show(error: String) {
        print("Trying to show error of base VC. Am I on main thread? \(Thread.isMainThread)")
        if Thread.callStackSymbols.count > 2 {
            print("Who called me: \(Thread.callStackSymbols[2])")
        }
        let alertController: UIAlertController = UIAlertController(title: error, message: nil, preferredStyle: .alert)
        //alertController.addAction(UIAlertAction(title: "OK".localized, style: .cancel))
        
        alertController.addAction(UIAlertAction(title: "OK".localized, style: .cancel) { [unowned self] _ in
            //self.openCameraScreen(delegate: self.cropDelegate!)
             self.navigationController?.popViewController(animated: false)
            self.delegate?.didFinishUserInfo()
        })

        present(alertController, animated: true, completion: nil)
    }
    
    
    
    private func setupNavigationBar() {

         let leftBarButtonItem: UIBarButtonItem = UIBarButtonItem(title: "BACK".localized,
                                                   style: .plain,
                                                   target: self,
                                                   action: #selector(onBackButtonClick))
         leftBarButtonItem.tintColor = UIColor.white
         self.navigationItem.setLeftBarButton(leftBarButtonItem, animated: false)
         self.navigationItem.title = "REPORT_AN_INCIDENT".localized

         let nav = self.navigationController?.navigationBar
         nav?.isTranslucent = false;
         nav?.barTintColor = UIColor.init(hexString: "3764BC")
         nav?.barStyle = UIBarStyle.black
         nav?.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
     }
    
    @objc func onBackButtonClick() {
           self.navigationController?.popViewController(animated: true)
       }
}