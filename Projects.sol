// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

// import "hardhat/console.sol";

contract Funds {

    ////// Contract Structure

    address public central;
    uint public balance;
    uint public spend;
    uint projectCount;

    struct Installment{
        uint project_id;
        uint installment_no;
        uint amount;
        uint time;
        address from;
        string from_name;
        address to;
        string to_name;
    }

    struct VendorPaid {
        uint project_id;
        string contract_name;
        address vendor_add;
        string vendor_name;
        uint amount;
        uint time;
        address from;
        string from_name;
    }

    struct Contract {
        string name;
        address dept_add;
        string dept_name;
        uint status;
        uint amount;
    }

    struct Project{
        uint id;
        string name;
        uint amount;
        uint installments;
        uint given;
        uint status;
        uint curr_inst;
        //uint level;
        address state_add;
        string state_name;
        address department_add;
        string department_name;
        Installment[] inst;
        VendorPaid[] vendor;
    }

    struct Government {
        address add;
        string name;
        uint balance;
        uint spend;
        uint[] projects;
    }

    struct Department {
        address under;
        string under_name;
        address add;
        string name;
        uint balance;
        uint spend;
        uint[] projects;
    }

    struct Vendor {
        address under;
        string under_name;
        address add;
        string name;
    }

    ///// Storing Structures
    Government[] gov;
    Department[] dept;
    Vendor[] vend;
    Contract[] cont;
    mapping(uint => Project) public projects;

    ///// Contract Functions
    // 1)Register Functions
    constructor() {
        central = msg.sender;
        balance=0;
        spend=0;
        projectCount=0;
    }
 
    function GovernmentCheck(string memory _name) public view returns (bool) {
        uint n=gov.length;
        for(uint i=0;i<n;i++){
            if(keccak256(abi.encodePacked(gov[i].name)) == keccak256(abi.encodePacked(_name))){
                return false;
            }
            if(msg.sender==gov[i].add){
                return false;
            }
        }
        return true;
    }

    function GovernmentRegister(address _add,string memory _name) public {
        Government memory temp;
        temp.add=_add;
        temp.name=_name;
        temp.balance=0;
        temp.spend=0;
        gov.push(temp);
    }

    function DepartmentCheck(string memory _name) public view returns (bool) {
        uint n=dept.length;
        for(uint i=0;i<n;i++){
            if(keccak256(abi.encodePacked(dept[i].name)) == keccak256(abi.encodePacked(_name))){
                return false;
            }
            if(msg.sender==dept[i].add){
                return false;
            }
        }
        return true;
    }

    function DepartmentRegister(address _under, string memory _under_name,address _add,string memory _name) public {
        Department memory temp;
        temp.under=_under;
        temp.under_name=_under_name;
        temp.add=_add;
        temp.name=_name;
        temp.balance=0;
        temp.spend=0;
        dept.push(temp);
    }
    
    function VendorCheck(string memory _name) public view returns (bool) {
        uint n=vend.length;
        for(uint i=0;i<n;i++){
            if(keccak256(abi.encodePacked(vend[i].name)) == keccak256(abi.encodePacked(_name))){
                return false;
            }
            if(msg.sender==vend[i].add){
                return false;
            }
        }
        return true;
    }

    function VendorRegister(address _under, string memory _under_name,address _add,string memory _name) public {
        vend.push(Vendor(_under,_under_name,_add,_name));
    }

    // 2) Login Functions
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

    function DepartmentLogin() public view returns (bool) {
        uint n=dept.length;
        for(uint i=0;i<n;i++){
            if(dept[i].add == msg.sender){
                return true;
            }
        }
        return false;
    }

    function VendorLogin() public view returns (bool) {
        uint n=vend.length;
        for(uint i=0;i<n;i++){
            if(vend[i].add == msg.sender){
                return true;
            }
        }
        return false;
    }

    // 3) Central Functions
    function GetBalance() public view returns (uint) {
        return balance;
    }

    function GetSpend() public view returns (uint) {
        return spend;
    }

    function getProjectCount() public view returns (uint) {
        return projectCount;
    }

    function AddFunds(uint _amount) public {
        balance=balance+_amount;
    }

    function getAllProjects() public view returns (Project[] memory) {
        Project[] memory allProjects = new Project[](projectCount);
        for(uint i = 0; i < projectCount; i++) {
            allProjects[i] = projects[i];
        }
        return allProjects;
    }

    function ApproveProjects(uint _id) public {
        projects[_id].status=1;
        projects[_id].curr_inst=1;
    }

    function SendInstallment1(uint _id) public {
        uint amt=(projects[_id].amount)/(projects[_id].installments);
        projects[_id].given=projects[_id].given+amt;
        projects[_id].inst.push(Installment(_id,projects[_id].curr_inst,amt,block.timestamp,central,"Central",projects[_id].state_add,projects[_id].state_name));
        uint n=gov.length;
        for(uint i=0;i<n;i++){
            if(gov[i].add == projects[_id].state_add){
                gov[i].balance=gov[i].balance+amt;
                break;
            }
        }
    }



    // 4) State Functions

    function StartProject(string memory _name,uint _amount,uint _installments,string memory _state_name, string memory _dept_name) public {
        address _state_add;
        address _dept_add;
        uint n=gov.length;
        uint m=dept.length;
        for(uint i=0;i<n;i++){
            if(keccak256(abi.encodePacked(gov[i].name)) == keccak256(abi.encodePacked(_state_name))){
                _state_add=gov[i].add;
                gov[i].projects.push(projectCount);
            }
        }
        for(uint i=0;i<m;i++){
            if(keccak256(abi.encodePacked(dept[i].name)) == keccak256(abi.encodePacked(_dept_name))){
                _dept_add=dept[i].add;
                dept[i].projects.push(projectCount);
            }
        }
    
        Project storage project = projects[projectCount]; 

        project.id=projectCount;
        projectCount=projectCount+1;
        project.name=_name;
        project.amount=_amount;
        project.given=0;
        project.status=0;
        project.curr_inst=0;
        project.installments=_installments;
        project.state_add=_state_add;
        project.state_name=_state_name;
        project.department_name=_dept_name;
        project.department_add=_dept_add;

    }

    function SendInstallment2(uint _id) public {
        uint amt=(projects[_id].amount)/(projects[_id].installments);
        projects[_id].inst.push(Installment(_id,projects[_id].curr_inst,amt,block.timestamp,projects[_id].state_add,projects[_id].state_name,projects[_id].department_add,projects[_id].department_name));
        projects[_id].curr_inst=projects[_id].curr_inst+1;
        if(projects[_id].curr_inst>projects[_id].installments){
            projects[_id].status=2;
        }
        uint n=dept.length;
        for(uint i=0;i<n;i++){
            if(dept[i].add == projects[_id].department_add){
                dept[i].balance=dept[i].balance+amt;
                break;
            }
        }
    }

    function getStateProjects() public view returns (Project[] memory) {
        uint n=gov.length;
        uint m;
        uint it;
        for(uint i=0;i<n;i++){
            if(gov[i].add == msg.sender){
                m=gov[i].projects.length;
                it=i;
                break;
            }
        }
        Project[] memory allProjects = new Project[](m);
        for(uint i = 0; i < m; i++) {
            allProjects[i] = projects[gov[it].projects[i]];
        }
        return allProjects;
    }

    // 5) Department Functions

    function OpenContract(string memory _name,string memory _dept_name,uint _amount) public {
        cont.push(Contract(_name,msg.sender,_dept_name,0,_amount));
    }

    function getContracts() public view returns (Contract[] memory) {
        uint n=cont.length;
        uint m=0;
        for(uint a=0;a<n;a++){
            if(msg.sender==cont[a].dept_add){
                m++;
            }
        }
        Contract[] memory allContracts= new Contract[](m);
        uint i=0;
        for(uint a=0;a<n;a++){
            if(msg.sender==cont[a].dept_add){
                allContracts[i]=cont[a];
                i=i+1;
            }
        }
        return allContracts;
    }

    function SendToVendor(uint _id,uint _amount,string memory _vendor_name, string memory _contract_name) public {
        uint n=dept.length;
        uint bal=0;
        uint it;
        for(uint i=0;i<n;i++){
            if(dept[i].add == projects[_id].department_add){
                bal=dept[i].balance;
                it=i;
                break;
            }
        }
        if(bal>=_amount){
            dept[it].balance=dept[it].balance-_amount;
            uint m=vend.length;
            address _vendor_add;
            for(uint i=0;i<m;i++){
                if(keccak256(abi.encodePacked(vend[i].name)) == keccak256(abi.encodePacked(_vendor_name))){
                    _vendor_add=vend[i].add;
                    break;
                }
            }
            projects[_id].vendor.push(VendorPaid(_id,_contract_name,_vendor_add,_vendor_name,_amount,block.timestamp,projects[_id].department_add,projects[_id].department_name));
        }
    }

    // 6) Track Project

    function TrackProject(uint _id) public view returns (Project memory) {
        return projects[_id];
    }

}