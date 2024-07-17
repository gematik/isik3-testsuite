@basis
@optional
@CodeSystem-Read
Feature: Lesen der Ressource CodeSystem (@CodeSystem-Read)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."
    Given Mit den Vorbedingungen:
    """
      - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
      - die ID der korrespondierenden FHIR-Ressource zu diesem Testdatensatz muss in der Konfigurationsvariable 'codesystem-read-id' hinterlegt sein.

      Legen Sie das folgende CodeSystem in Ihrem System an:
      Url: http://example.org/fhir/CodeSystem/TestKatalog
      Version: 1.0.0
      Name: testkatalog
      Status: aktiv
      Inhalt: Vollständig
      Enthaltener Code (Code, Display-Wert, Definition): test, Test, Dies ist ein Test-Code")
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And CapabilityStatement contains interaction "read" for resource "CodeSystem"

  Scenario: Read eines CodeSystem anhand der ID
    Then Get FHIR resource at "http://fhirserver/CodeSystem/${data.codesystem-read-id}" with content type "xml"
    And resource has ID "${data.codesystem-read-id}"
    And FHIR current response body is a valid isik3-basismodul resource and conforms to profile "https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKCodeSystem"

    And TGR current response with attribute "$..status.value" matches "active"
    And TGR current response with attribute "$..content.value" matches "complete"
    And TGR current response with attribute "$..url.value" matches "http://example.org/fhir/CodeSystem/TestKatalog"
    And TGR current response with attribute "$..name.value" matches "testkatalog"
    And TGR current response with attribute "$..version.value" matches "1.0.0"
    And TGR current response contains node "$..concept"
    And FHIR current response body evaluates the FHIRPath 'concept.where(code = "test" and display = "Test" and definition = "Dies ist ein Test-Code").exists()' with error message 'Das CodeSystem enthält keine Codes'
