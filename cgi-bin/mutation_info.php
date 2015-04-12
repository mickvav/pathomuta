<?php

// Соединяемся, выбираем базу данных
$link = mysql_connect('localhost', 'mutfreq', 'mutfreq')
    or die('Не удалось соединиться: ' . mysql_error());
mysql_select_db('mutfreq') or die('Не удалось выбрать базу данных');

// Выполняем SQL-запрос
if(preg_match("/^\d+$/",$_GET['rsId'])) {
$id=$_GET['rsId'];
$query = 'SELECT * FROM MUTATIONS_CLINVAR where ID='.$id;
$result = mysql_query($query) or die('Запрос не удался: ' . mysql_error());

$rsID = [
	"CLNDBN" => "Hereditary_leiomyomatosis_and_renal_cell_cancer|Hereditary_cancer-predisposing_syndrome",
	"GENEINFO" => "RER1:11079|PEX10:5192|ANKK1:4248",
	"INT" => TRUE,
	"U3" => TRUE,
	"U5" => TRUE,
	"SYN" => NULL,
	"NSF" => NULL,
	"NSM" => NULL,
	"NSN" => TRUE,
	"ASS" => NULL,
	"DSS" => NULL,
	"CLNDSDB" => "GeneReviews:MedGen:OMIM:OMIM:Orphanet|MedGen:SNOMED_CT",
	"CLNDSDBID" => "NBK1252:C1708350:150800:605839:ORPHA523|C0027672:699346009",
	"PMC" => TRUE,
	"rsID" => "334"
	];
 while ($row = mysql_fetch_assoc($result)) {
   foreach ($rsID as $key => $value) {
     $rsID[$key]=$row["info_".$key];
   }  
   $uuu = mutation_info($rsID);
   print json_encode($uuu);
 };
};



function mutation_info($rsID) {

	# Название ассоциированного заболевания
	if(isset( $rsID["CLNDBN"] ) && ( $rsID["CLNDBN"] != "not_specified" ) && ( $rsID["CLNDBN"] != "not_provided" )) {
		if (strpos($rsID["CLNDBN"], "|") !== FALSE) {
			$mutation_info["disease_name"] = explode("|", $rsID["CLNDBN"]);
			$mutation_info["disease_name"] = str_replace("_", " ", $mutation_info["disease_name"]);
			foreach ($mutation_info["disease_name"] as $key => $disease) {
				if ($disease == "not specified" || $disease == "not provided") {
					unset($mutation_info["disease_name"][$key]);
					}
				}
			}
		}

	# Аннотации по положению и типу мутации мутации. Переменные с underscore в начале имени - это ключи из clinvar'овского VCF-файла.

	if(		empty( 	$rsID["GENEINFO"] 						)	)	{	$mutation_info["type"]["intergenic"] = TRUE;	}
	if(		isset( 	$rsID["INT"]							)	)	{	$mutation_info["type"]["intron"] = TRUE;		}
	if(		isset( 	$rsID["U3"] ) || isset( $rsID["U5"]		)	)	{	$mutation_info["type"]["utrprime"] = TRUE;		}
	if(		isset( 	$rsID["SYN"] 							)	) 	{	$mutation_info["type"]["synonymous"] = TRUE;	}
	if(		isset( 	$rsID["NSF"] 							)	) 	{	$mutation_info["type"]["frameshift"] = TRUE;	}
	if(		isset( 	$rsID["NSM"] 							)	) 	{	$mutation_info["type"]["missense"] = TRUE;		}
	if(		isset( 	$rsID["NSN"] 							)	) 	{	$mutation_info["type"]["nonsense"] = TRUE;		}
	if(		isset( 	$rsID["ASS"] ) || isset( $rsID["DSS"]	)	)	{	$mutation_info["type"]["splice_site"] = TRUE;	}

	# Ссылки на сторонние базы данных и литературу. Переменная  $rsID - это число после букв "rs" в названии SNP.

	#OMIM, GeneReviews, MedGen, Orphanet, SNOMED_CT
	if(isset( $rsID["CLNDSDB"] )) {
	
		if (strpos($rsID["CLNDSDB"], "|") !== FALSE) {

			$db_names_pairs	=	explode("|", $rsID["CLNDSDB"]);
			$db_id_pairs 	=	explode("|", $rsID["CLNDSDBID"]);

			foreach ($db_names_pairs as $key1 => &$db_some_names) {
				if ($db_some_names === ".") { unset($db_names_pairs[$key1]); }
				$db_names_pairs1 = array_values($db_names_pairs);
				$db_some_names 	=	explode(":", $db_some_names);
				foreach ($db_some_names as $key => $value) {
					if ($value === ".") { unset($db_some_names[$key]); }
					$db_some_names1 = array_values($db_some_names);						
					}
				}

			foreach ($db_id_pairs as $key2 => &$db_some_ids) {
				if ($db_some_ids === ".") { unset($db_id_pairs[$key2]); }
				$db_id_pairs1 = array_values($db_id_pairs);
				$db_some_ids	=	explode(":", $db_some_ids);
				foreach ($db_some_ids as $key => $value) {
					if ($value === ".") { unset($db_some_ids[$key]); }					
					$db_some_ids1 = array_values($db_some_ids);
					}
				}
			for ($i=0; $i < count($db_names_pairs); $i++) {
			
				$databases[$i] = array_combine($db_id_pairs1[$i], $db_names_pairs1[$i]);
				foreach ($databases[$i] as $id => $db) {
				
					switch ($db) {
						case 'OMIM':			$mutation_info["reference"][$i]["omim"][] = "http://www.omim.org/entry/" . $id;					break;
						case 'GeneReviews':		$mutation_info["reference"][$i]["genereviews"][] = "http://www.ncbi.nlm.nih.gov/books/" . $id;	break;
						case 'MedGen':			$mutation_info["reference"][$i]["medgen"][] = "http://www.ncbi.nlm.nih.gov/medgen/" . $id;		break;
						case 'Orphanet':		$mutation_info["reference"][$i]["orphanet"][] = "http://www.orpha.net/consor/cgi-bin/Disease_Search_Simple.php?lng=EN&Disease_Disease_Search_diseaseType=ORPHA&Disease_Disease_Search_diseaseGroup=" . $id;		break;
						default: break;
						}
					}
				}
			}
		
		else {
			$db_some_names 	=	explode(":", $rsID["CLNDSDB"]);
			$db_some_ids	=	explode(":", $rsID["CLNDSDBID"]);
			$databases[0]	=	array_combine($db_some_ids, $db_some_names);
			foreach ($databases[0] as $id => $db) {
			
				switch ($db) {
					case 'OMIM':			$mutation_info["reference"][0]["omim"][] = "http://www.omim.org/entry/" . $id;					break;
					case 'GeneReviews':		$mutation_info["reference"][0]["genereviews"][] = "http://www.ncbi.nlm.nih.gov/books/" . $id;	break;
					case 'MedGen':			$mutation_info["reference"][0]["medgen"][] = "http://www.ncbi.nlm.nih.gov/medgen/" . $id;		break;
					case 'Orphanet':		$mutation_info["reference"][0]["orphanet"][] = "http://www.orpha.net/consor/cgi-bin/Disease_Search_Simple.php?lng=EN&Disease_Disease_Search_diseaseType=ORPHA&Disease_Disease_Search_diseaseGroup=" . $id;		break;
					default:
						break;
					}
			
				}

			}

		}


	#PubMed
	if (isset( $rsID["PMC"] )) {
		$mutation_info["reference"]["pubmed"] = "http://www.ncbi.nlm.nih.gov/pubmed?Db=pubmed&DbFrom=snp&Cmd=Link&LinkName=snp_pubmed_cited&IdsFromResult=" . $rsID["rsID"];
		}

	#ClinVar
	$mutation_info["reference"]["clinvar"] = "http://www.ncbi.nlm.nih.gov/clinvar/?term=rs" . $rsID["rsID"];

	#NCBI_Gene
	if(isset( $rsID["GENEINFO"] )) {
		
		if (strpos($rsID["GENEINFO"], "|") !== FALSE) {

			$pairs = explode("|", $rsID["GENEINFO"]);

			foreach ($pairs as $value) {
				$gene_info = explode(":", $value);
				$gene_id = $gene_info[1];
				$gene_abbreviation = $gene_info[0];
				$mutation_info["gene_info"]["gene_abbreviation"][] = $gene_abbreviation;
				$mutation_info["gene_info"]["gene_id"][] = $gene_id;
				$mutation_info["gene_info"]["gene_href"][] = 'http://www.ncbi.nlm.nih.gov/gene/' . $gene_id;
				}
		
			}
		
		else {
			$gene_info = explode(":", $rsID["GENEINFO"]);
			$gene_id = $gene_info[1];
			$gene_abbreviation = $gene_info[0];
			$mutation_info["gene_info"]["gene_abbreviation"][] = $gene_abbreviation;
			$mutation_info["gene_info"]["gene_id"][] = $gene_id;
			$mutation_info["gene_info"]["gene_href"][] = 'http://www.ncbi.nlm.nih.gov/gene/' . $gene_id;
			}

		}

	#dbSNP
	$mutation_info["reference"]["dbsnp"] = "http://www.ncbi.nlm.nih.gov/SNP/snp_ref.cgi?searchType=adhoc_search&type=rs&rs=rs" . $rsID["rsID"];

	return $mutation_info;
}

?>
