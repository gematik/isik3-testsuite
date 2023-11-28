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
      - die ID der korrespondierenden FHIR-Ressourcen zu diesem Testdatensatz müssen in der medikation.yaml eingegeben worden sein.
      
      Legen Sie folgende Medikationsverabreichung in Ihrem System an:
      Status: abgeschlossen
      Referenziertes Medikament: Beliebiges als Rate applizierbares Medikament
      Dosis (Text): 1L Infusion mit Rate 50ml/h
      Dosis: 1000ml
      Dosis (Körperstelle SNOMED CT kodiert): Linke obere Hohlvene (Structure of ligament of left superior vena cava)
      Dosis (Verabreichungsrate): 50 ml/h
      Dosis (Route SNOMED CT kodiert): Intravenös (Intravenous)
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'rest.where(mode = "server").resource.where(type = "MedicationAdministration" and interaction.where(code = "read").exists()).exists()'

  Scenario: Read einer MedicationAdministration mit Rateangaben anhand der ID
    Then Get FHIR resource at "http://fhirserver/MedicationAdministration/${data.medicationadministration-read-rate-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'id.replaceMatches("/_history/.+","").matches("${data.medicationadministration-read-rate-id}")' with error message 'ID der Ressource entspricht nicht der angeforderten ID'
    And FHIR current response body is a valid CORE resource and conforms to profile "http://hl7.org/fhir/StructureDefinition/MedicationAdministration"
    And FHIR current response body is a valid ISIK3 resource and conforms to profile "https://gematik.de/fhir/isik/v3/Medikation/StructureDefinition/ISiKMedikationsVerabreichung"
    And FHIR current response body evaluates the FHIRPath "dosage.where(text = '1L Infusion mit Rate 50ml/h' and dose.where(code = 'mL' and system = 'http://unitsofmeasure.org' and unit = 'mL' and value = '1000').exists()).exists()" with error message 'Die Dosis entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "dosage.rate.numerator.where(value = 50 and unit = 'mL' and code = 'mL' and system = 'http://unitsofmeasure.org').exists() and dosage.rate.denominator.where(value = 1 and unit = 'h' and code = 'h' and system = 'http://unitsofmeasure.org').exists()" with error message 'Die Rate entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "dosage.route.coding.where(system='http://snomed.info/sct' and code='255560000').exists()" with error message 'Die Route entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "dosage.site.coding.where(code = '6073002' and system = 'http://snomed.info/sct').exists()" with error message 'Die Körperstelle der Verabreichung entspricht nicht dem Erwartungswert'
