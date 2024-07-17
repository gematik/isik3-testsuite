@basis
@mandatory
@Condition-Read-Active
Feature: Lesen der Ressource Condition (@Condition-Read-Active)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die zuvor angelegte Ressource bei einer Suche anhand des Parameters finden und in den Suchergebnissen zurückgeben (SEARCH)."
    Given Mit den Vorbedingungen:
    """
      - Die Testfälle Patient-Read, Encounter-Read-In-Progress müssen zuvor erfolgreich ausgeführt worden sein.
      - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
      - die ID der korrespondierenden FHIR-Ressource zu diesem Testdatensatz muss in der Konfigurationsvariable 'condition-read-active-id' hinterlegt sein.

      Erfassen Sie folgende Diagnose:
      Klinischer Status: active (falls vom System unterstützt)
      Katalog: http://fhir.de/CodeSystem/bfarm/icd-10-gm
      Katalogversion: Aktuell
      Code: F71.0
      Dokumentationsdatum: 2021-02-12
      Referenzierter Patient: Der Patient aus Testfall Patient-Read
      Kontakt: Der Kontakt aus Testfall Encounter-Read-In-Progress
      Notiz: Testnotiz
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And CapabilityStatement contains interaction "read" for resource "Condition"

  Scenario: Read einer Condition anhand der ID
    Then Get FHIR resource at "http://fhirserver/Condition/${data.condition-read-active-id}" with content type "xml"
    And FHIR current response body is a valid isik3-basismodul resource and conforms to profile "https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKDiagnose"
    And FHIR current response body evaluates the FHIRPath 'id.replaceMatches("/_history/.+","").matches("\\b${data.condition-read-active-id}$")' with error message 'Der erwartete Code ist nicht vorhanden oder ein verpflichtender Wert fehlt'
    And FHIR current response body evaluates the FHIRPath 'code.coding.where(system = "http://fhir.de/CodeSystem/bfarm/icd-10-gm" and code = "F71.0" and version.exists()).exists()' with error message 'Referenzierter Patient entspricht nicht dem Erwartungswert'
    And element "subject" references resource with ID "${data.patient-read-id}" with error message "Referenzierter Fall entspricht nicht dem Erwartungswert"
    And FHIR current response body evaluates the FHIRPath "clinicalStatus.empty() or (clinicalStatus.coding.code contains 'active')" with error message 'clinical Status nicht active'
    And FHIR current response body evaluates the FHIRPath 'recordedDate.toString().contains("2021-02-12")' with error message 'Die Diagnose enthält nicht den erwarteten Beginn des Krankheitsbildes'
    And FHIR current response body evaluates the FHIRPath 'note.text = "Testnotiz"' with error message 'Die Notiz entspricht nicht dem Erwartungswert'
