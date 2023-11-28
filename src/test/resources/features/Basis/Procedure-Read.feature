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
        - die ID der korrespondierenden FHIR-Ressource zu diesem Testdatensatz muss im basis.yaml eingegeben worden sein.

        Testdatensatz (Name: Wert)
        Legen Sie folgende Prozedur in Ihrem System an:
        Patientenbezug: Patient aus dem Testfall Patient-Read
        Kontaktbezug: Kontakt aus dem Testfall Encounter-Read-In-Progress
        Art der Prozedur: chirurgischer Eingriff
        OPS-Code: 5-470.11
        OPS-Katalog Version: beliebige gültige Katalogversion
        Status: Durchgeführt
        Durchführungsdatum: 2020-04-23
        Notiz: Testnotiz
        Dokumentationsdatum: 2020-04-23
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'rest.where(mode = "server").resource.where(type = "Procedure" and interaction.where(code = "read").exists()).exists()'

  Scenario: Read einer Prozedur anhand ihrer ID
    Then Get FHIR resource at "http://fhirserver/Procedure/${data.procedure-read-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'id.replaceMatches("/_history/.+","").matches("${data.procedure-read-id}")' with error message 'ID der Ressource entspricht nicht der angeforderten ID'
    And FHIR current response body is a valid CORE resource and conforms to profile "http://hl7.org/fhir/StructureDefinition/Procedure"
    And FHIR current response body is a valid ISIK3 resource and conforms to profile "https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKProzedur"
    And TGR current response with attribute "$..status.value" matches "completed"
    And FHIR current response body evaluates the FHIRPath 'category.coding.where(code = "387713003" and system = "http://snomed.info/sct").exists()' with error message 'Die Procedure-Ressource enthält keine korrekte Kategorisierung'
    And FHIR current response body evaluates the FHIRPath 'code.coding.where(code = "5-470.11" and system = "http://fhir.de/CodeSystem/bfarm/ops" and version.exists()).exists()' with error message 'Die Procedure-Ressource enthält keine korrekte OPS-Kodierung'
    And FHIR current response body evaluates the FHIRPath "code.coding.where(code = '6025007' and system = 'http://snomed.info/sct').exists()" with error message 'Die Procedure-Ressource enthält keine korrekte SNOMED-CT-Kodierung'
    And FHIR current response body evaluates the FHIRPath 'subject.reference.replaceMatches("/_history/.+","").matches("${data.patient-read-id}")' with error message 'Referenzierter Patient entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath 'encounter.reference.replaceMatches("/_history/.+","").matches("${data.encounter-read-in-progress-id}")' with error message 'Referenzierter Patient entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath 'performed.toString().contains("2020-04-23")' with error message 'Die Prozedur enthält kein Durchführungsdatum'
    And FHIR current response body evaluates the FHIRPath 'note.where(text = "Testnotiz").exists()' with error message 'Die Notiz entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath 'extension.where(url = "http://fhir.de/StructureDefinition/ProzedurDokumentationsdatum" and value.toString().contains("2020-04-23")).exists()' with error message 'Das Dokumentationsdatum entspricht nicht dem Erwartungswert'
