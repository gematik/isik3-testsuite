@dokumentenaustausch
@terminplanung
@mandatory
@Binary-Read
Feature: Lesen der Ressource Binary (@Binary-Read)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."
    Given Mit den Vorbedingungen:
    """
      - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
      - die ID der korrespondierenden FHIR-Ressource zu diesem Testdatensatz muss in der Konfigurationsvariable 'binary-read-id' hinterlegt sein.

      Legen Sie die folgenden Binärdaten in Ihrem System an:
      Mime-Type: text/plain
      Textuelle Daten (UTF-8, LF (Unix)): Test
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And CapabilityStatement contains interaction "read" for resource "Binary"

  Scenario: Read von Binärdaten im FHIR-Format anhand der ID
    Then Get FHIR resource at "http://fhirserver/Binary/${data.binary-read-id}" with content type "xml"
    And resource has ID "${data.binary-read-id}"
    And FHIR current response body is a valid isik3-basismodul resource and conforms to profile "https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKBinary"
    And TGR current response with attribute "$..contentType.value" matches "text/plain"
    And TGR current response with attribute "$..data.value" matches "VGVzdA=="
