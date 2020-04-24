/**
 *Submitted for verification at Etherscan.io on 2019-07-12
*/

pragma solidity >=0.4.22 <0.6.0;

contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}
/// inspiré de
/// https://www.toshblocks.com/solidity/complete-example-voting-ballot-smart-contract/
/// et
/// https://medium.freecodecamp.org/developing-an-ethereum-decentralized-voting-application-a99de24992d9

/// TODO :
/// Utiliser SafeMath
/// mettre une date de fin à un certain vote



contract Voting {
  
    struct Voter {
        uint8 nbVote; // nombre de votes utilisables
        //uint8[] votesList; // liste des votes distribuées en fonction de l'id du projet (exemple : si le voteur donne 1 vote au projet 2 et 9 au projet 3 on aura [0,1,9])
    }

    struct Project {
        uint voteCount;
        bytes32 name; // Nom rapide pour s'assurer que projet "Projet DataScience" dans la Blockchain correspond bien à "Projet DataScience" dans la BDD
        uint8 id;
    }

    address chairperson; // celui qui déploie le contrat a des droits particuliers comme voir où en sont les votes + distribuer le droit de voter à des gens
    mapping(address => Voter) voters;
    Project[] projects;
    Project[] projects2;

    event hasVoted(uint8 nbVotes, uint8 projectID, address voter, uint time);

    constructor () public {
      chairperson = msg.sender;
      projects.push(Project({
          name : 'projetTampon',
          voteCount: 0,
          id : 0
      }));
      projects2 = projects;
    }
    
    /// Create a new ballot to choose one of `projectNames`.
    function createVote (bytes32[] memory projectNames) public {
      if (msg.sender != chairperson) return;
        // For each of the provided project names, create a new projet object and add it to the end of the array, and creates an id
        for (uint8 i = 0; i < projectNames.length; i++) {
            // `Project({...})` creates a temporary
            // project object and `projects.push(...)`
            // appends it to the end of `projects`.
            projects.push(Project({
                name: projectNames[i],
                voteCount: 0,
                id : i+1
            }));
        }
    }

    /// Give $(toVoter) the right to vote on this ballot.
    /// May only be called by $(chairperson).
    function giveRightToVote(address[] memory toVoters, uint8 nbOfVotes) public {
        if (msg.sender != chairperson) return;
        for (uint i = 0; i < toVoters.length; i++) {
            voters[toVoters[i]] = Voter({nbVote : nbOfVotes}); // on ajoute notre voteur dans le mapping de voteurs <-> addresses
        }
        // emit event
    }

    /// Give $(vote) vote(s) to projet $(toProject).
    function vote(uint8 toProject, uint8 voteFor) public {
        Voter storage sender = voters[msg.sender];
        if (sender.nbVote < voteFor || toProject >= projects.length) return; // TODO : add une erreur explicite pour les 2 cas : projet en dehors du scope et nb de vote insuffisant. Ou alors à fiare dans le front ?
        projects[toProject].voteCount += voteFor; // use safemath
        sender.nbVote -= voteFor; // use safemath
        emit hasVoted(voteFor, toProject, msg.sender, uint(now));
    }
    
    // votes dispos
    function getAvailableVotes() public view returns(uint8) {
      return voters[msg.sender].nbVote;
    }

    // Retourne le nom du projet $projectID
    // NB : on ne peut pas retourner d'array en solidity
    function getProjectName(uint8 projectID) public view returns (bytes32) {
        return (projects[projectID].name);
    }

    // Afficher le projet i de la liste des projets + le nb de votes
    // On boucle sur cette fonction jusqu'à getProjectCount pour afficher tous les projets
    function getProject(uint i) public view returns (bytes32, uint) {
       // require (msg.sender == chairperson); // TODO : ajouter en fonction du temps //NB : ne marche pas vraiment, on peut view avec n'importe quel addresse si on veut
        return (projects[i].name, projects[i].voteCount);
    }

    // Pour faciliter la boucle des fonctions au dessus
    function getProjectCount() public view returns (uint) {
        return projects.length;
    }

    // deletes all projects
    function cleanProjects() public {
        require (msg.sender == chairperson);
        projects = projects2;
    }
}
