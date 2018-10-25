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

		
//Se aquela alocação(Policia, Local, Tempo) ocorre
dvar boolean x[policiais,localizacoes,periodos];

//Se aquela alocação(Camera, Local) ocorre
dvar boolean y[cameras,localizacoes];

//Quanto violencia foi diminuida daquele local(Permite valor maior)
dvar int q[localizacoes,periodos];

//Variavel logica, tc<q: tc   else: q
dvar int v[localizacoes,periodos];

maximize
    //maximizar a diminuição do crime
	sum(l in localizacoes, p in periodos) v[l,p];
	
subject to {
	forall(po in policiais){
		forall(p in periodos){	
			//Garantir que uma policia não vai ser alocada em multiplos locais no mesmo horário 	
			sum(l in localizacoes) x[po,l,p] == 1;
		}						
	}
	
	forall(l in localizacoes){
			forall(p in periodos : p > 1 && p <= numPeriodos)	{			
				//Garantir que um policial só poderá para um local adjacente, respeitando sua capacidade de movimentação
				forall(po in policiais : po.tipo == "pé")
					x[po,l,p] - sum(l2 in localizacoes: item(l2.distancias,l.id) < 2) x[po,l2,p+1] <= 0;	
				forall(po in policiais : po.tipo == "carro")
				    x[po,l,p] - sum(l2 in localizacoes: item(l2.distancias,l.id) < 3) x[po,l2,p+1] <= 0;
				forall(po in policiais : po.tipo == "moto")
					x[po,l,p] - sum(l2 in localizacoes: item(l2.distancias,l.id) < 4) x[po,l2,p+1] <= 0;	
			}
 	}				
	
	forall(ca in cameras){
	  	//Garantir que uma câmera não vai ser alocada em multiplos locais
	  	sum(l in localizacoes) y[ca,l] == 1;
	}

	forall(l in localizacoes){
		forall(p in periodos){	
			//Setar a quantidade de crime 'q' a ser reduzida daquele local
			sum(po in policiais) x[po,l,p] * item(l.taxaCrime,p) 
			+ sum(po in policiais, l2 in localizacoes : item(l2.distancias,l.id) == 1) x[po,l2,p] * item(l.taxaCrime,p)* 0.5
			+ sum(po in policiais, l2 in localizacoes : item(l2.distancias,l.id) == 2) x[po,l2,p] * item(l.taxaCrime,p)* 0.25
			+ sum(po in policiais, l2 in localizacoes : item(l2.distancias,l.id) == 3) x[po,l2,p] * item(l.taxaCrime,p)* 0.1  == q[l,p];
			//Restrição lógica para limitar o ‘v’
			v[l,p] <= q[l,p];
			//Restrições lógicas para garantir que a taxa de crime não será negativa
			v[l,p] <=  item(l.taxaCrime,p);
		}		
	}	
	
}







