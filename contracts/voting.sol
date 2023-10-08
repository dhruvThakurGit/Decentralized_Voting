// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract VotingSystem {

    // Structure of 3 Main Parties
    address public admin;

    struct Candidate {
        uint id;
        string name;
        string proposal;
        uint voteCount;
    }

    struct Voter {
        uint id;
        string name;
        uint votesLeft;
        string[] votedFor;
        bool registered;
    }


    // Variables which store the Parties
    Candidate[] public candidates;
    mapping(address => Voter) public voters;
    address[] public votersAddress;


    uint8 electionState;
    // 0 - Not Started
    // 1 - In Progress
    // 2 - Ended


    // Intialization as mentioned in writeup
    uint candID;
    uint voteID;
    constructor()  {
      admin = msg.sender;
      electionState = 0;
      voteID = 0;
      candID = 0;
    }


    // All the types of modifiers
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the admin can call this function");
        _;
    }
    modifier onlyState0() {
        require(electionState == 0 , "This can only be called before the election starts");
        _;
    }
    modifier onlyState1(){
        require(electionState == 1 , "This can only be called while the election is ongoing");
        _;
    }
    modifier onlyState2(){
        require(electionState == 2 , "This can only be called after the election ends");
        _;
    }
    modifier registered(){
        require(voters[msg.sender].registered==true,"You are not a registered Voter");
        _;
    }
    modifier eligibleCandidate(){
        require(voters[msg.sender].votesLeft>0,"You do not have any votes left to give");
        _;
    }
    modifier candidateExist(){
        require(candidates.length>0,"No registered candidates to vote to");
        _;
    }
    modifier voterExist(){
        require(votersAddress.length>0,"No registered voters to vote");
        _;
    }


    // Functions to register Candidates and Voters
    function addCandidate(string memory _name, string memory _proposal) public onlyAdmin onlyState0 {
        candidates.push(Candidate(candID,_name, _proposal, 0));
        candID += 1;
    }
    function registerVoter(address _voterAddress,string memory _name) public onlyAdmin onlyState0 {
        require(voters[_voterAddress].registered==false, "Voter is already registered.");
        votersAddress.push(_voterAddress);
        string[] memory emptyVotedToArray;
        voters[_voterAddress] = Voter(voteID,_name,1,emptyVotedToArray,true);
        voteID += 1;
    }


    // Functions to change election state
    function startElection() public onlyAdmin onlyState0 candidateExist{
        electionState = 1;
    }
    function endElection() public onlyAdmin onlyState1{
        electionState = 2;
    }
    function resetElection() public onlyAdmin onlyState2{
        electionState = 0;
    }


    // Functions to display all and individual Candidates and Voters
    function displayAllCandidates() public view candidateExist returns(Candidate[] memory) {
        return candidates;
    }
    function displayCandidateByID(uint _ID) public view candidateExist returns(uint, string memory, string memory) {
        return (candidates[_ID].id,candidates[_ID].name,candidates[_ID].proposal);
    }
    function displayAllVoters() public view voterExist returns(Voter[] memory){
        uint n = votersAddress.length;
        Voter[] memory result = new Voter[](n);
        for (uint i = 0; i < n; i++) {
            result[i] = voters[votersAddress[i]];
        }
        return result;
    }
    function displayVoterByID(uint _ID) public view voterExist returns(uint, string memory, uint,string[] memory) {
        Voter memory voter = voters[votersAddress[_ID]];
        return (voter.id,voter.name,voter.votesLeft,voter.votedFor);
    }


    // Casting vote
    function castVote(uint _CandID) public onlyState1 registered eligibleCandidate candidateExist(){
        voters[msg.sender].votesLeft -= 1;
        candidates[_CandID].voteCount += 1;
        string memory candName = candidates[_CandID].name;
        voters[msg.sender].votedFor.push(candName);
    }


    // Calculate and return Winner
    function displayWinner() public view onlyState2 returns(Candidate memory){
        Candidate memory winner;
        for (uint i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > winner.voteCount) {
                winner = candidates[i];
            }
        }
        return winner;
    }


    // Delegation (Implemented such that multiple votes can be chained [a->b->c->a] )
    function delegateAllVote(address _delegatee) public onlyState1 voterExist registered eligibleCandidate{
        voters[_delegatee].votesLeft += voters[msg.sender].votesLeft;
        voters[msg.sender].votesLeft = 0;
    }

    
}

