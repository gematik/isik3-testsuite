@basis
@mandatory
@RelatedPerson-Read
Feature: Lesen der Ressource RelatedPerson (@RelatedPerson-Read)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."
    Given Mit den Vorbedingungen:
    """
        - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
        - die ID der korrespondierenden FHIR-Ressource zu diesem Testdatensatz muss in der basis.yaml eingegeben worden sein.

        Testdatensatz (Name: Wert)
        Legen Sie folgende Angehörige in Ihrem System an:
        Vorname: Maxine
        Nachname: Mustermann
        Patientenbezug: Beliebig (Bitte ID in der basis.yaml eingeben)
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'rest.where(mode = "server").resource.where(type = "RelatedPerson" and interaction.where(code = "read").exists()).exists()'

  Scenario: Read einer RelatedPerson-Ressource anhand ihrer ID
    Then Get FHIR resource at "http://fhirserver/RelatedPerson/${data.relatedperson-read-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'id.replaceMatches("/_history/.+","").matches("${data.relatedperson-read-id}")' with error message 'ID der Ressource entspricht nicht der angeforderten ID'
    And FHIR current response body is a valid CORE resource and conforms to profile "http://hl7.org/fhir/StructureDefinition/RelatedPerson"
    And FHIR current response body is a valid ISIK3 resource and conforms to profile "https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKAngehoeriger"
    And TGR current response with attribute "$..name.given.value" matches "Maxine"
    And TGR current response with attribute "$..name.family.value" matches "Mustermann"
    And FHIR current response body evaluates the FHIRPath 'patient.reference.replaceMatches("/_history/.+","").matches("${data.patient-read-id}")' with error message '${data.patient-read-id} ist nicht als Patient eingetragen'
