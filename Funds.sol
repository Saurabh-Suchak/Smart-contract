// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

// import "hardhat/console.sol";

contract Funds {
    address public central;
    uint public balance;
    uint public spend;
    // uint projectCount;

    struct Allocated{
        uint amount;
        uint time;
    }

    struct Government {
        address add;
        string gov_type;
        string name;
        uint balance;
        uint spend;
        string email;
        string pin;
        string password;
    }

    // struct Department{
    //     address add;
    //     string dep_type;
    //     string name;
    //     uint balance;
    //     uint spend;
    // }

    struct Project{
        string project_name;
        uint amount;
        uint installment;  // number of installments
        // uint[] status      
        uint status;
        uint curr_installement;
        string[][] track;
        address[][] vendors;
        uint[][] vendor_amount;
    }
  
    // struct Transactions {
    //     address from;
    //     address to;
    //     string from_name;
    //     string to_name;
    //     uint time;
    //     uint amount;
    //     string project_name;
    // }

    Allocated[] public alloc;
    Government[] public gov;
    // Transactions[] public transactions;
    Project[] public project;

    constructor() {
        central = msg.sender;
        balance=0;
        spend=0;
        transactionCount=0;
        gov.push(Government(msg.sender,"Central","Central",0,0,"xyz@gmail.com","0000","pass"));
    }

    function CentralLogin() public view returns (bool) {
        if(msg.sender==central){
            return true;
        }
        else{
            return false;
        }
    }

    function GovernmentLogin() public view returns (bool) {
        uint n=gov.length;
        for(uint i=0;i<n;i++){
            if(gov[i].add == msg.sender){
                return true;
            }
        }
        return false;
    }

    function GovernmentDetails() public view returns (Government memory) {
        uint n=gov.length;
        for(uint i=0;i<n;i++){
            if(gov[i].add == msg.sender){
                return gov[i];
            }
        }
        string memory e="empty";
        Government memory empty=Government(address(0),e,e,0,0,"xyz@gmail.com","0000","pass");
        return empty;
    }

    function GetBalance() public view returns (uint) {
        return balance;
    }

    function GetSpend() public view returns (uint) {
        return spend;
    }

    function projectCount() public view returns (uint) {
        return project.length;
    }

    function AddFunds(uint _amount) public {
        gov[0].balance=balance+_amount;
        alloc.push(Allocated(_amount,block.timestamp));
        balance=balance+_amount;
    }

    function getAllocatedFunds() public view returns (Allocated[] memory) {
        return alloc;
    }

    function CheckRegister(string memory _name) public view returns (bool) {
        uint n=gov.length;
        for(uint i=0;i<n;i++){
            if(keccak256(abi.encodePacked(gov[i].name)) == keccak256(abi.encodePacked(_name))){
                return false;
            }
            if(msg.sender==gov[i].add){
                return false;
            }
        }
        //gov.push(Government(msg.sender,_govtype,_name,0,0));
        return true;
    }

    function Register(address _add,string memory _govtype,string memory _name, string memory _email,string memory _pin,string memory _pass) public {
        
        gov.push(Government(_add,_govtype,_name,0,0,_email,_pin,_pass));
    }

    function AllocateFunds(uint _amount, string memory _to, string memory _project) public {
        //// check if central login
        uint n=gov.length;
        uint ind;
        for(uint i=0;i<n;i++){
            if(keccak256(abi.encodePacked(gov[i].name)) == keccak256(abi.encodePacked(_to))){
                ind=i;
                break;
            }
        }
        balance=balance-_amount;
        spend=spend+_amount;
        gov[ind].balance=gov[ind].balance+_amount;
        gov[0].balance=balance;
        gov[0].spend=spend;
        transactions.push(Transactions(central,gov[ind].add,"Central",_to,block.timestamp,_amount,_project));
        transactionCount=transactionCount+1;
    }

    

    // function TransferFunds(uint _amount, string memory _to, string memory _project) public {
    //     uint n=gov.length;
    //     uint ind_from;
    //     uint ind_to;
    //     for(uint i=0;i<n;i++){
    //         if(keccak256(abi.encodePacked(gov[i].name)) == keccak256(abi.encodePacked(_to))){
    //             ind_to=i;
    //             break;
    //         }
    //     }

    //     for(uint i=0;i<n;i++){
    //         if(gov[i].add == msg.sender){
    //             ind_from=i;
    //             break;
    //         }
    //     }

    //     gov[ind_to].balance=gov[ind_to].balance+_amount;
    //     gov[ind_from].balance=gov[ind_from].balance-_amount;
    //     gov[ind_from].spend=gov[ind_from].spend+_amount;

    //     transactions.push(Transactions(msg.sender,gov[ind_to].add,gov[ind_from].name,_to,block.timestamp,_amount,_project));
        
    //     // transactionCount=transactionCount+1;
    // }

    
// for central to state or state to department
    function sendInstallment(uint _amount, string memory _to, string memory _project) public {
        uint n=gov.length;
        uint ind_from;
        uint ind_to;
        for(uint i=0;i<n;i++){
            if(keccak256(abi.encodePacked(gov[i].name)) == keccak256(abi.encodePacked(_to))){
                ind_to=i;
                break;
            }
        }

        for(uint i=0;i<n;i++){
            if(gov[i].add == msg.sender){
                ind_from=i;
                break;
            }
        }

        gov[ind_to].balance=gov[ind_to].balance+_amount;
        gov[ind_from].balance=gov[ind_from].balance-_amount;
        gov[ind_from].spend=gov[ind_from].spend+_amount;

        track.push((gov[ind_from].add,gov[ind_to].add));  // track contains address as (from, to)
        

        // update status of installment  will be in department to vendor function
    }

// send installments from department to vendor
    function sendInstallmentVendor(uint memory _amount, string memory _to, string memory _project) public {
        uint n=gov.length;
        uint ind_from;
        uint ind_to;
        for(uint i=0;i<n;i++){
            if(keccak256(abi.encodePacked(gov[i].name)) == keccak256(abi.encodePacked(_to))){
                ind_to=i;
                break;
            }
        }

        for(uint i=0;i<n;i++){
            if(gov[i].add == msg.sender){
                ind_from=i;
                break;
            }
        }

        gov[ind_to].balance=gov[ind_to].balance+_amount;
        gov[ind_from].balance=gov[ind_from].balance-_amount;
        gov[ind_from].spend=gov[ind_from].spend+_amount;

        track.push((gov[ind_from].add,gov[ind_to].add));  // track contains address as (from, to)
        

        // update status of installment  

        // assuming using status array, find the project from project array , update the installment status as 1(completed)
        // for(int i=0;i<project.length;i++){
        //     if(project[i]==_project){
        //         project[i].status.push(1);
        //     }
        // }
        
    }


    // function getAllTrancations() public view returns (Transactions[] memory) {
    //     return transactions;
    // }

    function getAllProjects() public view returns (Project[] memory){
        return projects;
    }

    function getAllGovernment() public view returns (Government[] memory) {
        return gov;
    }

    // function getAllGovernmentAllocatedTrancations() public view returns (Transactions[] memory) {

    //     uint count=transactions.length;
    //     uint n=0;

    //     for(uint i = 0; i < count; i++) {
    //         if(transactions[i].to == msg.sender){
    //             n=n+1;
    //         }
    //     }

    //     Transactions[] memory trans = new Transactions[](n);
    //     uint it=0;
    //     for(uint i = 0; i < count; i++) {
    //         if(transactions[i].to == msg.sender){
    //             trans[it]=transactions[i];
    //             it=it+1;
    //         }
    //     }

    //     return trans;
    // }

    function getAllGovernmentAllocatedProjects() public view returns (Project[] memory) {

        uint count=project.length;
        uint n=0;

        for(uint i = 0; i < count; i++) {
            if(project[i].to == msg.sender){
                n=n+1;
            }
        }

        Project[] memory proj = new Project[](n);
        uint it=0;
        for(uint i = 0; i < count; i++) {
            if(project[i].to == msg.sender){
                proj[it]=project[i];
                it=it+1;
            }
        }

        return proj;
    }


    function getAllGovernmentSpendTrancations() public view returns (Transactions[] memory) {

        uint count=transactions.length;
        uint n=0;

        for(uint i = 0; i < count; i++) {
            if(transactions[i].from == msg.sender){
                n=n+1;
            }
        }

        Transactions[] memory trans = new Transactions[](n);
        uint it=0;
        for(uint i = 0; i < count; i++) {
            if(transactions[i].from == msg.sender){
                trans[it]=transactions[i];
                it=it+1;
            }
        }

        return trans;
    }

    function trackProject(string project_name) public view returns  (Project memory){
        for(uint i=0;i<projects.length;i++){
            if(projects[i].name==project_name){
                return projects[i];
            }
        }
        string memory e="empty";
        Government memory empty=Government(address(0),e,e,0,0,"xyz@gmail.com","0000","pass");
        return empty;

    }

    function getAllGovernmentTrancations() public view returns (Transactions[] memory) {

        uint count=transactions.length;
        uint n=0;

        for(uint i = 0; i < count; i++) {
            if(transactions[i].from == msg.sender){
                n=n+1;
            }
            else if(transactions[i].to == msg.sender){
                n=n+1;
            }
        }

        Transactions[] memory trans = new Transactions[](n);
        uint it=0;
        for(uint i = 0; i < count; i++) {
            if(transactions[i].from == msg.sender){
                trans[it]=transactions[i];
                it=it+1;
            }
            else if(transactions[i].to == msg.sender){
                trans[it]=transactions[i];
                it=it+1;
            }
        }

        return trans;
    }

    function registerProject(string memory _project,uint memory _amount,uint memory _installment) public{
        //
        
         project.push(Project(_project,_amount,_installment,0,0,[],[])); // status is 0(waiting/not completed by default

         // if using status array- left to write project.push below

    }

    // function createProject(string memory _project, uint memory _amount, uint memory _installment) public {
    
    //     Project memory project_obj = Project({
    //         project_name: _project,
    //         amount: _amount,
    //         installment: _installment,
    //         status: 0,
    //         curr_installement: 0,
    //         track: new address[][](0),
    //         vendors: new address[][](0),
    //         vendor_amount: new uint[][](0)
    //     });


    // }

    // function createProject(string memory _project_name, uint memory _amount, uint memory _installment) public {
    //     // Initialize the Project struct with default values
    //     Project memory project_obj;
    //     project_obj.project_name = _project_name;
    //     project_obj.amount = _amount;
    //     project_obj.installment = _installment;
    //     //  dynamic arrays are automatically initialized as empty
    //     // project_obj.status = 0;
    //     // project_obj.curr_installement = 0;
    //     // project_obj.track = new address[][](0);
    //     // project_obj.vendors = new address[][](0);
    //     // project_obj.vendor_amount = new uint[][](0);
    // project.push(project_obj);

    // }

}
