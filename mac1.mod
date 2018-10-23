/*********************************************
 * OPL 12.8.0.0 Model
 * Author: Gabriel
 * Creation Date: 21/09/2018 at 09:58:40
 *********************************************/


int qtdCameras = ...;

int numPeriodos = ...;

{int} periodos = {p | p in 1..numPeriodos};

tuple Policial{
	key int id;
	string tipo;
}

tuple Camera{
	key int id;
}

{Policial} policiais = ...;
{Camera} cameras = ...;

tuple Vizinho{
	int vizinho;
	int distancia;
}

tuple Localizacao {
	key int id;
	{int} taxaCrime;
	{int} distancias_ids;
	{int} distancias;
}

{Localizacao} localizacoes = ...;

tuple AlocacaoPolicia {
	Policial policia;
	Localizacao localizacao;
	int tempo;
}


{AlocacaoPolicia} alocacoesP = 
		{<p, l, t> | p in policiais, l in localizacoes, t in periodos};


tuple AlocacaoCamera {
	Camera camera;
	Localizacao localizacao;
}

{AlocacaoCamera} alocacoesC = 
		{<c, l> | c in cameras, l in localizacoes};
		
tuple Adjacencia {
	Localizacao localizacao;
	int tempo;
}

{Adjacencia} adjacencias = 
		{<l, t> | l in localizacoes, t in periodos};

		
//Se aquela alocação(Policia, Local, Tempo) ocorre
dvar boolean x[alocacoesP];

//Se aquela alocação(Camera, Local) ocorre
dvar boolean y[alocacoesC];

//Quanto violencia foi diminuida daquele local(Permite valor maior)
dvar int q[adjacencias];

//Variavel logica, tc<q: tc   else: q
dvar int v[adjacencias];

maximize
    //maximizar a diminuição do crime
	sum(l in localizacoes, t in periodos) v[<l,t>];
	
subject to {
	forall(po in policiais){
		//Garantir que uma policia não vai ser alocada em multiplos locais no mesmo horário, no período inicial 	
		sum(<po,l,1> in alocacoesP) x[<po,l,1>] == 1;				
	}
	forall(l in localizacoes){
			forall(p in periodos : p > 1 && p <= numPeriodos)	{	
				forall(po in policiais : po.tipo == "pé")
					x[<po,l,p>] - sum(<po,l2 ,p2> in alocacoesP : item(l2.distancias,l.id) < 2 && p2 == p+1) x[<po,l2,p2>] >= 0;	
				forall(po in policiais : po.tipo == "carro")
				    x[<po,l,p>] - sum(<po,l2 ,p2> in alocacoesP : item(l2.distancias,l.id) < 3 && p2 == p+1) x[<po,l2,p2>] >= 0;
				forall(po in policiais : po.tipo == "moto")
					x[<po,l,p>] - sum(<po,l2 ,p2> in alocacoesP : item(l2.distancias,l.id) < 4 && p2 == p+1) x[<po,l2,p2>] >= 0;	
			}
 	}				
	
	forall(ca in cameras){
	  	//Garantir que uma câmera não vai ser alocada em multiplos locais
	  	sum(<ca,l> in alocacoesC) y[<ca,l>] == 1;
	}

	forall(<l,t> in adjacencias){	
		//Setar a quantidade de crime 'q' a ser reduzida daquele local
		sum(<po,l,t> in alocacoesP) x[<po,l,t>] * item(l.taxaCrime,t) + sum(<po,l2,t> in alocacoesP : item(l2.distancias,l.id) < 2) x[<po,l,t>] * item(l.taxaCrime,t)* 0.5
		+ sum(<po,l2,t> in alocacoesP : item(l2.distancias,l.id) < 3) x[<po,l,t>] * item(l.taxaCrime,t)* 0.25 + sum(<po,l2,t> in alocacoesP : item(l2.distancias,l.id) < 4) x[<po,l,t>] * item(l.taxaCrime,t)* 0.1  == q[<l,t>];
		//Restrição lógica para limitar o ‘v’
		v[<l,t>] <= q[<l,t>];
		//Restrições lógicas para garantir que a taxa de crime não será negativa
		v[<l,t>] <=  item(l.taxaCrime,t);
	}	
	
}







