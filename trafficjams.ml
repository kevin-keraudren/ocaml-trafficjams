type case_route = {voiture : bool; mutable vitesse : int; mutable tour : bool};;
open Random;;
#load "graphics.cma";;
open Graphics;;
Graphics.open_graph "";;

#use "topfind";;
#require "camlimages";;
#load "camlimages_graphics.cma";;
#load "camlimages_png.cma";; 
open Images;;
open Graphic_image;;

let n = size_x();;
let time = size_y();;
let i0 = n/2;;
let nb_voitures = 6;; (*j*)

(*_________________________________________________________________________________*)
let couleur = function
    |0-> set_color black
    |1-> set_color blue
    |2-> set_color cyan
    |3-> set_color yellow
    |4-> set_color magenta
    |5-> set_color red;; 

let imprime route t =
	let n = Array.length route in

	for i = 0 to n - 1 do
		let case = route.(i) in
		if case.voiture = true then
                  begin
                      let v = case.vitesse in
                      couleur v;
                      plot i (size_y() - t);
                  end
	done;;

(*_________________________________________________________________________________*)


let automate =

	let case_vide = {voiture = false; vitesse = 0; tour = false} in
	let route = Array.make n case_vide in

	let densite_i0 = ref 0. in
	let flux_i0 = ref 0. in

(*initialisation de la route*)
for i = 0 to n-1 do 
	let p = int nb_voitures in 
	if p = 0 then
	   route.(i) <- {voiture = true; vitesse = 0; tour = true};
done;

(*distance*)
let d i = 

	let compteur = ref 0 in
	let case = ref {voiture = false; vitesse = 0; tour=false} in

	case := route.((i +1) mod n);

	while !case.voiture = false do
		compteur := !compteur + 1 ;
		case := route.((i + (!compteur) +1) mod n)
	done;
!compteur
in

(*traitement des voitures*)
  for t = 1 to time do

		if route.(i0).voiture = true 
		  then densite_i0 := (!densite_i0) +. 1.;	

	for i = 0 to (n-1) do
		(*mouvement des vehicules*)
		let case = route.(i) in
		if case.voiture = true && case.tour = true then 
			if route.((i + case.vitesse) mod n).voiture =false then
				begin
				route.((i + case.vitesse) mod n) <- case;
				route.((i + case.vitesse) mod n).tour <- false;
				route.(i) <- case_vide;	
				(*mesure du flux entre i0 et (i0 + 1)*)
				if i <= i0 && (i + case.vitesse) >= i0 then flux_i0 := !flux_i0 +. 1.;
				end
	done;

	for i = 0 to (n-1) do

		let case = route.(i) in
		if case.voiture = true then 
			begin

		(*acceleration*)
			if (case.vitesse<5) && ((d i) > case.vitesse + 1) 
		  		then case.vitesse <- case.vitesse +1;
			case.tour<-true;

		(*ralentissement dû aux autres vehicules*)
			let j =(d i) in 
			if j <= case.vitesse && case.vitesse > 0
		  		then case.vitesse <- j-1;

		(*ralentissement aleatoire*)
			let p = int 10 in 
			if p = 1 && case.vitesse > 1
		  		then case.vitesse <- case.vitesse-1;

			end
	done;

  imprime route t;
  done;

(*calcul de la densite en i0*)
let a = (!densite_i0 /. (float_of_int time)) in
print_float a;
print_newline();

(*calcul du flux entre i0 et (i0 + 1)*)
let b = (!flux_i0 /. (float_of_int time)) in
print_float b;
print_newline();;

let img = Graphic_image.get_image 0 0 (Graphics.size_x ()) (Graphics.size_y ()) in
   Images.save "image.png" (Some Png) [] (Rgb24 img);;


(*_________________________________________________________________________________*)

