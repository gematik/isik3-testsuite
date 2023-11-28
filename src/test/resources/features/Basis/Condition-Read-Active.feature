@basis
@mandatory
@Condition-Read-Active
Feature: Lesen der Ressource Condition (@Condition-Read-Active)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die zuvor angelegte Ressource bei einer Suche anhand des Parameters finden und in den Suchergebnissen zurückgeben (SEARCH)."
    Given Mit den Vorbedingungen:
    """
      - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
      - die ID der korrespondierenden FHIR-Ressource zu diesem Testdatensatz muss in der Titus UI eingegeben worden sein.

      Testdatensatz (Name: Wert)
      Erfassen Sie folgende Diagnose:
      Klinischer Status: active
      Katalog: http://fhir.de/CodeSystem/bfarm/icd-10-gm
      Katalogversion: Aktuell
      Code: F71.0
      Beginn des Krankheitsbildes: 2021-01-01
      Referenzierter Patient: Beliebig (Bitte ID im basis.yaml eingeben)
      Notiz: Testnotiz
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'rest.where(mode = "server").resource.where(type = "Condition" and interaction.where(code = "read").exists()).exists()'

  Scenario: Read einer Condition anhand der ID
    Then Get FHIR resource at "http://fhirserver/Condition/${data.condition-read-active-id}" with content type "xml"
    And FHIR current response body is a valid CORE resource and conforms to profile "http://hl7.org/fhir/StructureDefinition/Condition"
    And FHIR current response body is a valid ISIK3 resource and conforms to profile "https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKDiagnose"
    And FHIR current response body evaluates the FHIRPath 'id.replaceMatches("/_history/.+","").matches("${data.condition-read-active-id}")' with error message 'Der erwartete Code ist nicht vorhanden oder ein verpflichtender Wert fehlt'
    And FHIR current response body evaluates the FHIRPath 'code.coding.where(system = "http://fhir.de/CodeSystem/bfarm/icd-10-gm" and code = "F71.0" and version.exists()).exists()' with error message 'Referenzierter Patient entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath 'subject.reference.replaceMatches("/_history/.+","").matches("${data.patient-read-id}")' with error message 'Referenzierter Fall entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath 'clinicalStatus.coding.code contains "active"' with error message 'clinical Status nicht active'
    And FHIR current response body evaluates the FHIRPath 'recordedDate.toString().contains("2021-01-01")' with error message 'Die Diagnose enthält nicht den erwarteten Beginn des Krankheitsbildes'
    And FHIR current response body evaluates the FHIRPath 'note.text = "Testnotiz"' with error message 'Die Notiz entspricht nicht dem Erwartungswert'
