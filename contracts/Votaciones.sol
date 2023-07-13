// SPDX-License-Identifier: MIT 
pragma solidity >=0.4.4 <=0.7.0;
pragma experimental ABIEncoderV2;

contract Votaciones{
    //variables
    //direccion del propietario del contrato
    address public owner;
    //mapping entre el nombre del candidato y sus datos personales
    mapping (string => bytes32) id_Candidato;
    //mapping entre el nombre del candidato y sus votos favorables
    mapping(string => uint) votos_Candidato;
    //lista para almacenar los nombres de los candidatos 
    string[] candidatos;
    //lista de votantes basados en el hash de su documento de identidad
    bytes32[] votantes;

    //constructor 
    constructor() {
        owner = msg.sender;
    }

    //permite a una persona inscribirse como candidato
    function Inscripcion(string memory _nombre, uint _edad, uint _id) public {
        bytes32 hash_Candidato = keccak256(abi.encodePacked(_nombre, _edad, _id));
        id_Candidato[_nombre] = hash_Candidato;
        candidatos.push(_nombre);
    }

    //permite a los ciudadanos votar a un candidato
    function VotarCandidato(string memory _nombreCandidato) public {
        bytes32 hashVotante = keccak256(abi.encodePacked(msg.sender));

        for (uint256 index = 0; index < votantes.length; index++) {
            require(votantes[index] != hashVotante, "Ya ha votado");
        }

        votantes.push(hashVotante);
        votos_Candidato[_nombreCandidato]++;
    }

    //Funcion auxiliar que transforma un uint a un string
    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }

    //ver los candidatos que se presentaron
    function VerCandidatos() public view returns(string[] memory){
        return candidatos;
    }

    //devuelve los votos que tiene el candidato
    function VerVotos(string memory _candidato) public view returns(uint){
        return votos_Candidato[_candidato];
    }

    //devuelve los resultados de la eleccion
    function VerResultados() public view returns(string memory){
        string memory resultados = "";

        for (uint256 index = 0; index < candidatos.length; index++) {
            resultados = string(abi.encodePacked(resultados, "(",candidatos[index], " - ",uint2str(VerVotos(candidatos[index])),") --- "));
        }

        return resultados;
    }

    //devuelve el ganador de la votacion
    function VerGanador() public view returns(string memory){
        string memory ganador = candidatos[0];
        bool empate = false;

        for (uint256 index = 0; index < candidatos.length; index++) {
            if(votos_Candidato[ganador] < votos_Candidato[candidatos[index]]){
                ganador = candidatos[index];
                empate = false;
            } else {
                if(votos_Candidato[ganador] == votos_Candidato[candidatos[index]]){
                    empate = true;
                }
            }
        }

        ganador = empate ? "Ha habido un empate" : ganador;
        return ganador;
    }
}