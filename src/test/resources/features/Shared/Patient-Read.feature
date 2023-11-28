@basis
@dokumentenaustausch
@terminplanung
@vitalparameter
@mandatory
@Patient-Read
Feature: Lesen der Ressource Patient (@Patient-Read)

  @vorbedingung
  Scenario: Vorbedingung
    Given Testbeschreibung: "Das zu testende System MUSS die angelegte Ressource bei einem HTTP GET auf deren URL korrekt und vollständig zurückgeben (READ)."
    Given Mit den Vorbedingungen:
    """
      - der Testdatensatz muss im zu testenden System gemäß der Vorgaben (manuell) erfasst worden sein.
      - die ID der korrespondierenden FHIR-Ressource zu diesem Testdatensatz muss in der shared.yaml eingegeben worden sein. (Name: Wert)

      Legen Sie den folgenden Patienten in Ihrem System an:
      Status: aktiv
      Vorname: Max
      Nachname: Graf von und zu Mustermann
      Geschlecht: männlich
      Addresse: Musterstraße 3, 1. Etage Hinterhaus, 1. Etage Hinterhaus, 9876 Musterdorf, Schweiz
      Stadtteil: Wiedikon
      Postfach: 4711 (selbe Stadt)
      Geburtsdatum: 12.5.1968
      Telefonnummer: 201-867-5309
      GKV-Versicherungsnummer: X485231029
    """

  Scenario: Read und Validierung des CapabilityStatements
    Then Get FHIR resource at "http://fhirserver/metadata" with content type "json"
    And FHIR current response body evaluates the FHIRPath 'rest.where(mode = "server").resource.where(type = "Patient" and interaction.where(code = "read").exists()).exists()'

  Scenario: Read eines Patienten anhand seiner ID
    Then Get FHIR resource at "http://fhirserver/Patient/${data.patient-read-id}" with content type "xml"
    And FHIR current response body evaluates the FHIRPath 'id.replaceMatches("/_history/.+","").matches("${data.patient-read-id}")' with error message 'ID der Ressource entspricht nicht der angeforderten ID'
    And FHIR current response body is a valid CORE resource and conforms to profile "http://hl7.org/fhir/StructureDefinition/Patient"
    And FHIR current response body is a valid ISIK3 resource and conforms to profile "https://gematik.de/fhir/isik/v3/Basismodul/StructureDefinition/ISiKPatient"
    And TGR current response with attribute "$..gender.value" matches "male"
    And TGR current response with attribute "$..active.value" matches "true"
    And TGR current response with attribute "$..birthDate.value" matches "1968-05-12"
    And FHIR current response body evaluates the FHIRPath "name.where(use='official').given.matches('Max')"
    And FHIR current response body evaluates the FHIRPath "name.where(use='official').family.matches('Graf von und zu Mustermann')"
    And FHIR current response body evaluates the FHIRPath "identifier.where(value = 'X485231029' and system = 'http://fhir.de/sid/gkv/kvid-10').exists()" with error message 'Die GKV Versicherungsnummer entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "address.where(type = 'both' and city = 'Musterdorf' and postalCode = '9876' and country = 'CH' and line.extension.where(url = 'http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-streetName' and value = 'Musterstraße').exists() and line.extension.where(url = 'http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-houseNumber' and value = '3').exists() and line.extension.where(url = 'http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-additionalLocator' and value = '1. Etage Hinterhaus').exists()).exists()" with error message 'Die Adresse entspricht nicht dem Erwartungswert'
    And FHIR current response body evaluates the FHIRPath "address.extension.where(url = 'http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-precinct' and (value as string) = 'Wiedikon').exists()" with error message 'Stadtteil ist falsch angegeben'
    And FHIR current response body evaluates the FHIRPath "address.where(type = 'postal' and city = 'Musterdorf' and postalCode = '9876' and country = 'CH' and line.where(extension.url = 'http://hl7.org/fhir/StructureDefinition/iso21090-ADXP-postBox' and extension.value = 'Postfach 4711') = 'Postfach 4711').exists()" with error message 'Das Postfach entspricht nicht dem Erwartungswert'
