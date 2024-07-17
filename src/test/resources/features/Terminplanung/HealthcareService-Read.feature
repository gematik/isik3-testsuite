@terminplanung
@mandatory
@HealthcareService-Read
Feature: Lesen der Ressource HealthcareService (@HealthcareService-Read)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."
    Given Mit den Vorbedingungen:
    """
      - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
      - die ID der korrespondierenden FHIR-Ressource zu diesem Testdatensatz muss in der Konfigurationsvariable 'healthcareservice-read-id' hinterlegt sein.

      Legen Sie ie folgende Behandlungseinheit in Ihrem System an:
      Status: aktiv
      Behandlungstyp: Beliebig (bitte das CodeSystem und den Code in den Konfigurationsvariablen 'healthcareservice-read-servicetype-system' und 'code = 'healthcareservice-read-servicetype-code' hinterlegen)
      Fachrichtung: Neurologie
      Name: Allgemeine Beratungsstelle der Fachabteilung Neurologie
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And CapabilityStatement contains interaction "read" for resource "HealthcareService"

  Scenario: Read eines medizinischen Behandlungseinheit anhand der ID
    Then Get FHIR resource at "http://fhirserver/HealthcareService/${data.healthcareservice-read-id}" with content type "xml"
    And resource has ID "${data.healthcareservice-read-id}"
    And FHIR current response body is a valid isik3-terminplanung resource and conforms to profile "https://gematik.de/fhir/isik/v3/Terminplanung/StructureDefinition/ISiKMedizinischeBehandlungseinheit"
    And TGR current response with attribute "$..active.value" matches "true"
    And FHIR current response body evaluates the FHIRPath "type.where(coding.where(code = '${data.healthcareservice-read-servicetype-code}' and system = '${data.healthcareservice-read-servicetype-system}').exists()).exists()" with error message 'Der Typ entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "specialty.where(coding.where(code = '142' and system = 'urn:oid:1.2.276.0.76.5.114').exists()).exists()" with error message 'Die Fachrichtung entspricht nicht dem Erwartungswert'
    And TGR current response with attribute "$..name.value" matches "Allgemeine Beratungsstelle der Fachabteilung Neurologie"
    