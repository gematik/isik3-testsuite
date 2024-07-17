@medikation
@mandatory
@Medication-Read
Feature: Lesen der Ressource Medication (@Medication-Read)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."
    Given Mit den Vorbedingungen:
    """
      - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
      - die ID der korrespondierenden FHIR-Ressource zu diesem Testdatensatz muss in der Konfigurationsvariable 'medication-read-id' hinterlegt sein.

      Legen Sie folgendes Medikament in Ihrem System an:
      ATC-Code: V03AB23
      Display-Wert: Acetylcystein
      Status: aktiv
      Chargennummer: 123
      Menge: 600mg pro Tablette
      Rezeptur: Verweisen Sie auf einen beliebigen Bestandteil (Medication)
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And CapabilityStatement contains interaction "read" for resource "Medication"

  Scenario: Read eines Medikaments anhand der ID
    Then Get FHIR resource at "http://fhirserver/Medication/${data.medication-read-id}" with content type "xml"
    And resource has ID "${data.medication-read-id}"
    And FHIR current response body is a valid isik3-medikation resource and conforms to profile "https://gematik.de/fhir/isik/v3/Medikation/StructureDefinition/ISiKMedikament"
    And TGR current response with attribute "$..Medication.status.value" matches "active"
    And TGR current response with attribute "$..batch.lotNumber.value" matches "123"
    And FHIR current response body evaluates the FHIRPath "code.coding.where(code = 'V03AB23' and system = 'http://fhir.de/CodeSystem/bfarm/atc' and display = 'Acetylcystein').exists()" with error message 'Der Code entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "amount.numerator.where(value ~ 600 and system = 'http://unitsofmeasure.org' and code = 'mg').exists()" with error message 'Die Menge entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "ingredient.item.exists()" with error message 'Es existiert keine Referenz auf die Zutat'
