@medikation
@mandatory
@MedicationAdministration-Read-Rate
Feature: Lesen der Ressource MedicationAdministration (Rate) (@MedicationAdministration-Read-Rate)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."
    Given Mit den Vorbedingungen:
    """
      - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
      - die ID der korrespondierenden FHIR-Ressourcen zu diesem Testdatensatz muss in der Konfigurationsvariable 'medicationadministration-read-rate-id' hinterlegt sein.
      
      Legen Sie folgende Medikationsverabreichung in Ihrem System an:
      Status: abgeschlossen
      Referenziertes Medikament: Beliebiges als Rate applizierbares Medikament
      Dosis (Text): Beliebig (nicht leer)
      Dosis (Gesamt): 1000ml
      Dosis (Körperstelle SNOMED CT kodiert): Linke obere Hohlvene (Structure of ligament of left superior vena cava)
      Dosis (Verabreichungsrate): 50 ml/h
      Dosis (Route SNOMED CT kodiert): Intravenös (Intravenous)
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And CapabilityStatement contains interaction "read" for resource "MedicationAdministration"

  Scenario: Read einer MedicationAdministration mit Rateangaben anhand der ID
    Then Get FHIR resource at "http://fhirserver/MedicationAdministration/${data.medicationadministration-read-rate-id}" with content type "xml"
    And resource has ID "${data.medicationadministration-read-rate-id}"
    And FHIR current response body is a valid isik3-medikation resource and conforms to profile "https://gematik.de/fhir/isik/v3/Medikation/StructureDefinition/ISiKMedikationsVerabreichung"
    And FHIR current response body evaluates the FHIRPath "dosage.text.empty().not()" with error message 'Der Text der Dosis ist nicht angegeben'
    And FHIR current response body evaluates the FHIRPath "dosage.site.coding.where(code = '6073002' and system = 'http://snomed.info/sct' and display.empty().not()).exists()" with error message "Die Körperstelle der Dosis entspricht nicht dem Erwartungswert"
    And FHIR current response body evaluates the FHIRPath "dosage.route.coding.where(code = '255560000' and system = 'http://snomed.info/sct' and display.empty().not()).exists()" with error message "Die Route der Dosis entspricht nicht dem Erwartungswert"
    And FHIR current response body evaluates the FHIRPath "dosage.dose.code = 'mL' and dosage.dose.system = 'http://unitsofmeasure.org' and dosage.dose.unit = 'mL' and dosage.dose.value ~ 1000" with error message "Die Gesamtdosis entspricht nicht dem Erwartungswert"
    And FHIR current response body evaluates the FHIRPath "(dosage.rate.is(Quantity) and (dosage.rate.code = 'mL/h' and dosage.rate.system = 'http://unitsofmeasure.org' and dosage.rate.unit = 'mL/h' and dosage.rate.value ~ 50 ) ) or ( dosage.rate.is(Ratio) and ( dosage.rate.numerator.value ~ 50 and dosage.rate.numerator.unit = 'mL' and dosage.rate.numerator.code = 'mL' and dosage.rate.numerator.system = 'http://unitsofmeasure.org' and dosage.rate.denominator.value ~ 1 and dosage.rate.denominator.unit = 'h' and dosage.rate.denominator.code = 'h' and dosage.rate.denominator.system = 'http://unitsofmeasure.org') )" with error message "Die Verabreichungsrate entspricht nicht dem Erwartungswert"
