@basis
@mandatory
@Procedure-Read
Feature: Lesen der Ressource Procedure gegen procedure-read (@Procedure-Read)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."
    Given Mit den Vorbedingungen:
    """
        - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
        - die ID der korrespondierenden FHIR-Ressource zu diesem Testdatensatz muss in der Konfigurationsvariable 'procedure-read-id' hinterlegt sein.

        Testdatensatz (Name: Wert)
        Legen Sie folgende Prozedur in Ihrem System an:
        Patientenbezug: Patient aus dem Testfall Patient-Read
        Kontaktbezug: Kontakt aus dem Testfall Encounter-Read-In-Progress
        Art der Prozedur: chirurgischer Eingriff
        OPS-Code: 5-470.11
        OPS-Katalog Version: beliebige gültige Katalogversion
        Status: Durchgeführt
        Durchführungsdatum: 2021-02-13
        Notiz: Testnotiz
        Dokumentationsdatum: 2021-02-13
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And CapabilityStatement contains interaction "read" for resource "Procedure"

  Scenario: Read einer Prozedur anhand ihrer ID
    Then Get FHIR resource at "http://fhirserver/Procedure/${data.procedure-read-id}" with content type "xml"
    And resource has ID "${data.procedure-read-id}"
    And FHIR current response body is a valid isik3-basismodul resource and conforms to profile "https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKProzedur"
    And TGR current response with attribute "$..status.value" matches "completed"
    And FHIR current response body evaluates the FHIRPath 'category.coding.where(code = "387713003" and system = "http://snomed.info/sct").exists()' with error message 'Die Procedure-Ressource enthält keine korrekte Kategorisierung'
    And FHIR current response body evaluates the FHIRPath 'code.coding.where(code = "5-470.11" and system = "http://fhir.de/CodeSystem/bfarm/ops" and version.exists()).exists()' with error message 'Die Procedure-Ressource enthält keine korrekte OPS-Kodierung'
    And FHIR current response body evaluates the FHIRPath "code.coding.where(code = '6025007' and system = 'http://snomed.info/sct').exists()" with error message 'Die Procedure-Ressource enthält keine korrekte SNOMED-CT-Kodierung'
    And element "subject" references resource with ID "${data.patient-read-id}" with error message "Referenzierter Patient entspricht nicht dem Erwartungswert"
    And element "encounter" references resource with ID "${data.encounter-read-in-progress-id}" with error message "Referenzierter Patient entspricht nicht dem Erwartungswert"
    And FHIR current response body evaluates the FHIRPath 'performed.toString().contains('2021-02-13') or ( performed.start.toString().contains('2021-02-13') and performed.end.toString().contains('2021-02-13') )' with error message 'Die Prozedur enthält kein Durchführungsdatum'
    And FHIR current response body evaluates the FHIRPath 'note.where(text = "Testnotiz").exists()' with error message 'Die Notiz entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath 'extension.where(url = "http://fhir.de/StructureDefinition/ProzedurDokumentationsdatum" and value.toString().contains("2021-02-13")).exists()' with error message 'Das Dokumentationsdatum entspricht nicht dem Erwartungswert'
