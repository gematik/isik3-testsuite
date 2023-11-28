@basis
@dokumentenaustausch
@terminplanung
@vitalparameter
@mandatory
@Patient-Read-Extended
Feature: Lesen der Ressource Patient (@Patient-Read-Extended)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."
    Given Mit den Vorbedingungen:
    """
      - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
      - die ID der korrespondierenden FHIR-Ressource zu diesem Testdatensatz sowie die zugewiesene einrichtungsinterne Patienten-ID muss in der shared.yaml eingegeben worden sein.

      Testdatensatz (Name: Wert)
      Vorname: An&na,Vic$tor|a
      Nachname: Gräfin Müßtermánn (Mit Extensions)
      Geschlecht: divers
      Geburtsdatum: 20.06.1955
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'rest.where(mode = "server").resource.where(type = "Patient" and interaction.where(code = "read").exists()).exists()'

  Scenario: Read eines Patienten anhand seiner ID
    Then Get FHIR resource at "http://fhirserver/Patient/${data.patient-read-extended-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'id.replaceMatches("/_history/.+","").matches("${data.patient-read-extended-id}")' with error message 'ID der Ressource entspricht nicht der angeforderten ID'
    And FHIR current response body is a valid CORE resource and conforms to profile "http://hl7.org/fhir/StructureDefinition/Patient"
    And FHIR current response body is a valid ISIK3 resource and conforms to profile "https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKPatient"
    And TGR current response with attribute "$..gender.value" matches "other"
    And TGR current response with attribute "$..birthDate.value" matches "1955-06-20"
    And FHIR current response body evaluates the FHIRPath "name.where(use='official').given.matches('An&na,Vic$tor|a')"
    And FHIR current response body evaluates the FHIRPath "name.where(use='official').family.matches('Gräfin Müßtermánn')"
    And FHIR current response body evaluates the FHIRPath "gender.extension.where(url = 'http://fhir.de/StructureDefinition/gender-amtlich-de' and value.code = 'D' and value.system = 'http://fhir.de/CodeSystem/gender-amtlich-de').exists()" with error message 'Das Geschlecht entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "name.family.extension.where(url = 'http://fhir.de/StructureDefinition/humanname-namenszusatz' and value = 'Gräfin').exists()" with error message 'Der Namenszusatz ist nicht vorhanden'
    And FHIR current response body evaluates the FHIRPath "name.family.extension.where(url = 'http://hl7.org/fhir/StructureDefinition/humanname-own-name' and value = 'Müßtermánn').exists()" with error message 'Der Nachname ist nicht ohne Namenszusatz vorhanden'
